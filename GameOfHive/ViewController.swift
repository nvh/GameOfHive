//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
   
// queue enforcing serial grid creation
let gridQueue = DispatchQueue(label: "grid_queue", attributes: [])


let cellSize: CGSize = {
    let cellHeight: CGFloat = 26 // must be even!!!! We use half height and half width for drawing
    var cellWidth = hexagonWidthForHeight(cellHeight)
    return CGSize(width: cellWidth, height: cellHeight)
}()

func hexagonWidthForHeight(_ height: CGFloat) -> CGFloat {
    var cellWidth = (sqrt((3 * height * height) / 16)) * 2
    cellWidth = ceil(cellWidth).truncatingRemainder(dividingBy: 2) == 1 ? floor(cellWidth) : ceil(cellWidth)
    return cellWidth
}

let lineWidth: CGFloat = 1.0

class ViewController: UIViewController {
    let rules = Rules.defaultRules
    
    var grid: HexagonGrid!
    var cells: [HexagonView] = []
    var timer: Timer!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonsVisibleConstraint: NSLayoutConstraint?
    @IBOutlet weak var buttonsHiddenConstraint: NSLayoutConstraint?
    @IBOutlet weak var clearButtonHiddenConstraint: NSLayoutConstraint?
    @IBOutlet weak var clearButtonVisibleConstraint: NSLayoutConstraint?

    var playing: Bool {
        return timer != nil
    }
    
    let messageOverlay = UIControl()
    let messageHUD = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    // MARK: UIViewController
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscapeLeft,.landscapeRight]
    }
    
    var shouldShowMessage: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGrid()

        let threeFingerTap = UITapGestureRecognizer(target: self, action: #selector(toggleButtons(_:)))
        #if TARGET_IPHONE_SIMULATOR
        threeFingerTap.numberOfTouchesRequired = 2
        #else
        threeFingerTap.numberOfTouchesRequired = 3
        #endif
        contentView.addGestureRecognizer(threeFingerTap)
        
        view.addSubview(messageOverlay)
        messageOverlay.constrainToView(view)
        messageOverlay.addTarget(self, action: #selector(dismissMessageOverlay), for: .touchUpInside)
        
        
        messageOverlay.addSubview(messageHUD)
        messageHUD.isUserInteractionEnabled = false
        messageHUD.translatesAutoresizingMaskIntoConstraints = false
        messageHUD.centerXAnchor.constraint(equalTo: messageOverlay.centerXAnchor).isActive = true
        messageHUD.centerYAnchor.constraint(equalTo: messageOverlay.centerYAnchor).isActive = true
        let halfHeight = messageHUD.heightAnchor.constraint(equalTo: messageOverlay.heightAnchor, multiplier: 0.5)
        halfHeight.priority = .defaultHigh
        halfHeight.isActive = true
        let minHeight = messageHUD.heightAnchor.constraint(greaterThanOrEqualToConstant: 250)
        minHeight.priority = .required
        minHeight.isActive = true
        messageHUD.heightAnchor.constraint(equalTo: messageHUD.widthAnchor, multiplier: 1/(sqrt(3) / 2)).isActive = true

        let messageView = UILabel()

        messageHUD.contentView.addSubview(messageView)
        
        messageView.numberOfLines = 0
        messageView.adjustsFontSizeToFitWidth = true
        messageView.textAlignment = .center
        messageView.constrainToView(messageHUD, margin: 20)
        messageView.text = "Tap with three fingers to show and hide the controls"
        messageView.font = UIFont(name: "Raleway-Medium", size: 20)
        messageView.textColor = UIColor.lightAmberColor

        let drawingGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDrawWithFinger))
        view.addGestureRecognizer(drawingGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskLayer = CAShapeLayer()
        maskLayer.path = hexagonPath(messageHUD.frame.size, lineWidth: 5)
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor.lightAmberColor.cgColor
        borderLayer.lineWidth = 5
        borderLayer.fillColor = UIColor.clear.cgColor
        messageHUD.layer.mask = maskLayer
        messageHUD.layer.addSublayer(borderLayer)
    }
    
    var undoFileName: URL {
        return documentsDirectory.appendingPathComponent("undo.json")
    }
    
    func saveUndo() {
        do {
            try grid.save(undoFileName)
        } catch {
            print("error saving undo", error)
        }
    }
    
    func loadUndo() {
        do {
            let grid = try HexagonGrid.load(undoFileName)
            loadGrid(grid)
        } catch {
            print("error loading undo", error)
        }
    }
    
    func saveHive() {
        do {
            let image = contentView.captureScreenshot(scale: 0.5)
            try HiveManager.sharedSaved.save(grid: grid, image: image)

        } catch let error {
            print("Error saving grid",error)
        }
    }
    
    func loadHive(with identifier: String? = nil) {
        do {
            let hive = try HiveManager.sharedSaved.loadHive(identifier)
            load(hive: hive)
        } catch {
            print("error loading hive", error)
        }
    }
    
    func loadGrid(_ grid: HexagonGrid) {
        stop()
        self.grid = gridFromViewDimensions(view.bounds.size, cellSize: cellSize, gridType: .template(grid))
        drawGrid(self.grid, animationDuration: 0.1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let menu = segue.destination as? MenuController, segue.identifier == "presentMenu" else {
            return
        }
        
        menu.delegate = self
    }
    
    func load(hive: Hive) {
        do {
            let grid = try hive.grid()
            loadGrid(grid)
        } catch {
            print("error loading hive",error)
        }
    }
    
    func openMenu() {
        stop()
        performSegue(withIdentifier: "presentMenu", sender: self)
    }
    
    @objc func toggleButtons(_ gestureRecognizer: UIGestureRecognizer?) {
        if let constraint = buttonsVisibleConstraint, constraint.isActive {
            buttonsVisibleConstraint?.isActive = false
            buttonsHiddenConstraint?.isActive = true
            clearButtonVisibleConstraint?.isActive = false
            clearButtonHiddenConstraint?.isActive = true
        } else if let constraint = buttonsHiddenConstraint, constraint.isActive {
            buttonsHiddenConstraint?.isActive = false
            buttonsVisibleConstraint?.isActive = true
            clearButtonHiddenConstraint?.isActive = false
            clearButtonVisibleConstraint?.isActive = true
        }
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func dismissMessageOverlay() {
        self.toggleButtons(nil)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.messageHUD.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }) { finished in
            self.messageOverlay.removeFromSuperview()
            self.togglePlayback()
        }
    }
    
    
    // MARK: Grid
    func createGrid() {
        assert(timer == nil, "Expect not running")
        assert(grid == nil, "Expect grid does not exist")

        grid = gridFromViewDimensions(view.bounds.size, cellSize: cellSize, gridType: .random)

        let viewYSpacing = (3 * cellSize.height) / 4
        let xOffset = -cellSize.width/2
        let yOffset = -(viewYSpacing)
        
        grid.forEach { hexagon in
            let row = hexagon.location.row
            let column = hexagon.location.column
            let x = xOffset + (row & 1 == 0 ? (cellSize.width * CGFloat(column)) : (cellSize.width * CGFloat(column)) + (cellSize.width * 0.5))
            let y = yOffset + (viewYSpacing * CGFloat(row))
            let frame = CGRect(x: x, y: y, width: cellSize.width, height: cellSize.height)
            let cell = HexagonView(frame: frame)
            cell.coordinate = hexagon.location
            cell.alive = hexagon.active
            cell.alpha = cell.alive ? HexagonView.aliveAlpha : HexagonView.deadAlpha
            cell.hexagonViewDelegate = self
            cells.append(cell)
            contentView.addSubview(cell)
        }
    }
    
    func updateGrid() {
        gridQueue.async {
            let grid = self.rules.perform(self.grid)
            self.grid = grid
            DispatchQueue.main.async {
                self.drawGrid(grid)
            }
        }
    }
    
    func drawGrid(_ grid: HexagonGrid, animationDuration: Double = 0.05) {
        assert(Thread.isMainThread, "Expect main thread")
        
        // split cells by needed action. filter unchanged cells
        var cellsToActivate: [HexagonView] = []
        var cellsToDeactivate: [HexagonView] = []
        
        var isCompletelyDead = true
        cells.forEach { cell in
            if let hexagon = grid.hexagon(atLocation: cell.coordinate) {
                switch (cell.alive, hexagon.active) {
                case (false, true):
                    isCompletelyDead = false
                    cellsToActivate.append(cell)
                case (true, false):
                    cellsToDeactivate.append(cell)
                case (true, true):
                    isCompletelyDead = false
                default:()
                }
                cell.alive = hexagon.active
            }
        }
        // animate changes
        if cellsToActivate.count > 0 {
            let config = AnimationConfiguration(startValue: HexagonView.deadAlpha, endValue: HexagonView.aliveAlpha, duration: animationDuration)
            Animator.addAnimationForViews(cellsToActivate, configuration: config)
        }
        if cellsToDeactivate.count > 0 {
            let config = AnimationConfiguration(startValue: HexagonView.aliveAlpha, endValue: HexagonView.deadAlpha, duration: animationDuration)
            Animator.addAnimationForViews(cellsToDeactivate, configuration: config)
        }
        
        if isCompletelyDead {
            self.stop()
            return
        }
    }

    
    // MARK: Timer
    func createTimer() -> Timer {
        return Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick(_ timer: Timer) {
        updateGrid()
    }
    
    func cellsUserInteraction(enabled: Bool) {
        cells.forEach { cell in
            cell.isUserInteractionEnabled = enabled
        }
    }
    
    fileprivate func start() {
        
        cellsUserInteraction(enabled: false)
        timer?.invalidate()
        timer = createTimer()
        timer.fire()
        playButton.setImage(UIImage(named: "button_stop"), for: UIControlState())
    }
    
    fileprivate func stop() {
        guard playing else {
            return
        }
        
        cellsUserInteraction(enabled: true)
        
        timer?.invalidate()
        timer = nil
        playButton.setImage(UIImage(named: "button_play"), for: UIControlState())
    }
    
    fileprivate func clear() {
        stop()
        var size: CGSize = .zero
        if (Thread.isMainThread) {
            size = self.view.bounds.size
        } else {
            DispatchQueue.main.sync {
                size = self.view.bounds.size
            }
        }
        gridQueue.async {
            let grid = gridFromViewDimensions(size, cellSize: cellSize, gridType: .empty)
            self.grid = grid
            DispatchQueue.main.async {
                self.drawGrid(grid)
            }
        }
    }

    @objc func didDrawWithFinger(_ recognizer: UIPanGestureRecognizer) {
        guard let cellView = view.hitTest(recognizer.location(in: view), with: nil) as? HexagonView else {
            return
        }
        cellView.alive = true
        userDidUpateCell(cellView)
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return .bottom
    }
}

// MARK: HexagonView Delegate
extension ViewController: HexagonViewDelegate {
    func userDidUpateCell(_ cell: HexagonView) {
        gridQueue.async {
            let grid = self.grid.setActive(cell.alive, atLocation: cell.coordinate)
            
            self.grid = grid
            
            DispatchQueue.main.async{
                let alive = cell.alive
                let start: CGFloat = alive ? HexagonView.deadAlpha : HexagonView.aliveAlpha
                let end: CGFloat = alive ? HexagonView.aliveAlpha : HexagonView.deadAlpha
                let duration: CFTimeInterval = 0.2
                let config = AnimationConfiguration(startValue: start, endValue: end, duration: duration)
                Animator.addAnimationForViews([cell], configuration: config)
            }
        }
    }
}

//MARK: Shake!
extension ViewController {
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }
        
        clear()
    }
}

extension ViewController: MenuDelegate {
    func menuDidClose(menu: MenuController) {
        toggleButtons(nil)
        menu.delegate = nil
    }
}

extension ViewController {
    @IBAction func togglePlayback() {
        if playing {
            stop()
        } else {
            saveUndo()
            start()
        }
    }
    
    @IBAction func didTapUndo(_ sender: UIButton) {
        loadUndo()
    }
    
    @IBAction func didTapStep(_ sender: UIButton) {
        stop()
        updateGrid()
    }
    
    @IBAction func didTapLoad(_ sender: UIButton) {
        loadHive()
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        saveHive()
    }
    
    @IBAction func didTapMenu(_ sender: UIButton) {
        toggleButtons(nil)
        openMenu()
    }
    
    @IBAction func didTapClearButton(_ sender: UIButton) {
        clear()
    }
}

