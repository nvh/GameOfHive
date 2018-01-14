//
//  MenuView.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 21-05-15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

enum MenuPressedState {
  case show
  case hide
}

protocol MenuDelegate: class {
    func menuDidClose(menu: MenuController)
    func load(template: Template)
}

enum Content {
    case webpage(URL)
    case templatePicker
}

struct MenuItemModel {
    let title: String
    let content: Content
}

class MenuController: UIViewController {

    @IBOutlet weak var centerButton: HiveButton!
    
    weak var delegate: MenuDelegate?

    fileprivate let buttonModels = [
        MenuItemModel(
            title: "About",
            content: .webpage(URL(string: "https://tomasharkema.github.io/GameOfHive/about.html")!)),
        MenuItemModel(
            title: "Credits",
            content: .webpage(URL(string: "https://tomasharkema.github.io/GameOfHive/credits.html")!)),
        MenuItemModel(
            title: "Templates",
            content: .templatePicker),
        MenuItemModel(
            title: "Saved Hives",
            content: .webpage(URL(string: "https://tomasharkema.github.io/GameOfHive/")!)),
        MenuItemModel(
            title: "Donate",
            content: .webpage(URL(string: "https://tomasharkema.github.io/GameOfHive/donate.html")!)),
        MenuItemModel(
            title: "Video",
            content: .webpage(URL(string: "https://tomasharkema.github.io/GameOfHive/video.html")!)),]


    fileprivate var buttons = [HiveButton]()
    fileprivate var openedHive: HiveButton?
    fileprivate var height: CGFloat = 200

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // because, you know, constraints...
        height = centerButton.bounds.height

        addButtons()
        animateIn()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.landscapeLeft,.landscapeRight]
    }

    let offset: CGFloat = 4

    var initialPoint: CGPoint {
        // calculate initial degrees for offset
        let initial_x = hexagonWidthForHeight((height / 2.0)) + (pow(offset, 2) / 2.0)
        let initial_y = (height / 2.0) + (pow(offset, 2) / 2.0)
        return CGPoint(x: initial_x, y: initial_y)
    }

    var degrees: CGFloat {
        return atan(initialPoint.x / initialPoint.y) * (180 / .pi)
    }

    var distance: CGFloat {
        return sqrt(pow(initialPoint.x, 2) + pow(initialPoint.y, 2))
    }

    func pointForDegrees(_ offset: CGFloat, degrees: CGFloat) -> CGPoint {
        let xOff = offset * cos(degrees * (.pi / 180))
        let yOff = offset * sin(degrees * (.pi / 180))
        return CGPoint(x: round(xOff), y: round(yOff))
    }

    func addButtons() {

        let buttonsAndCoordinates: [(MenuItemModel, CGPoint)] = buttonModels.enumerated().map { (idx, el) in
            let offsetDegrees = (CGFloat(idx - 90) * 60.0) + degrees
            let point = pointForDegrees(distance, degrees: offsetDegrees - 90)
            return (el, point)
        }

        let buttons = buttonsAndCoordinates.map { (model, point) -> HiveButton in
            let center = CGPoint(x: point.x + (self.view.frame.width / 2), y: point.y + (self.view.frame.height / 2))
            let rect = CGRect(x: center.x, y: center.y, width: hexagonWidthForHeight(height/2), height: height/2)

            let button = HiveButton(type: .custom)
            button.style = .small
            button.frame = rect
            button.setTitle(model.title, for: UIControlState())
            button.titleLabel?.textColor = UIColor.black
            button.center = center
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            return button
        }

        buttons.forEach { button in
            self.view.insertSubview(button, belowSubview: centerButton)
        }

        self.buttons = buttons
    }

    fileprivate func animateMenuState(_ pressedState: MenuPressedState, completion: ((Bool) -> ())? = nil) {
        switch pressedState {
        case .show:
            self.view.backgroundColor = UIColor.backgroundColor.withAlphaComponent(0)
            centerButton.transform = CGAffineTransform(rotationAngle: .pi / 2).scaledBy(x: CGFloat.leastNormalMagnitude, y: CGFloat.leastNormalMagnitude)
            self.buttons.enumerated().forEach { (idx, button) in

                let tx = self.view.center.x - button.center.x
                let ty = self.view.center.y - button.center.y

                let rotation = CGAffineTransform(rotationAngle: .pi / 2)
                let translate = CGAffineTransform(translationX: tx, y: ty)
                let transform = rotation.concatenating(translate)
                button.transform = transform
            }
        case .hide:
            centerButton.transform = CGAffineTransform.identity
            self.buttons.forEach { $0.transform = CGAffineTransform.identity }
        }

        let animations = {
            switch pressedState {
            case .show:
                self.centerButton.transform = CGAffineTransform.identity
                self.buttons.forEach { $0.transform = CGAffineTransform.identity }

            case .hide:
                self.centerButton.transform = CGAffineTransform(rotationAngle: .pi / 2).scaledBy(x: 0.01, y: 0.01)
                self.buttons.enumerated().forEach { (idx, button) in

                    let tx = self.view.center.x - button.center.x
                    let ty = self.view.center.y - button.center.y

                    let rotation = CGAffineTransform(rotationAngle: .pi / 2)
                    let translate = CGAffineTransform(translationX: tx, y: ty)
                    let transform = rotation.concatenating(translate)
                    let scale = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(transform)
                    button.transform = scale
                }
            }
            
            self.view.setNeedsDisplay()
        }
        
        switch pressedState {
        case .show:
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .curveEaseIn, animations: animations, completion: completion)

        case .hide:
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: animations, completion: completion)
        }


        UIView.animate(withDuration: 0.4, animations: {
            self.view.backgroundColor = UIColor.backgroundColor
                .withAlphaComponent(pressedState == MenuPressedState.show ? 0.75 : 0)
        }) 
    }
    
    func animateIn() {
        animateMenuState(.show)
    }
    
    func animateOut() {
        animateMenuState(.hide) { completed in
            if completed {
                self.dismiss(animated: false, completion: nil)
                self.delegate?.menuDidClose(menu: self)
            }
        }
    }
    
    var isDismissing = false
    @IBAction func dismissButtonPressed(_ sender: AnyObject) {
        guard !isDismissing else {
            return
        }

        isDismissing = true
        animateOut()
    }
}

//MARK: Menu Button Handling

protocol SubMenuDelegate: class {
    func contentWillClose(openedViewController: UIViewController)
}


extension MenuController: SubMenuDelegate {
    func contentWillClose(openedViewController: UIViewController) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.openedHive?.transform = .identity
            }, completion: nil)
    }
}

extension MenuController: TemplatePickerDelegate {
    func didSelectTemplate(template: Template) {
        delegate?.load(template: template)
        animateOut()
    }
}

extension MenuController {
    func animateButtonToControllerPoint(hiveButton: HiveButton, completion: ((Bool) -> ())?) {
        let endX = (hiveButton.frame.width / 2) + 30
        let endY = (hiveButton.frame.height / 2) + 30

        let tx = endX - hiveButton.center.x
        let ty = endY - hiveButton.center.y
        let _: Double = sqrt(pow(Double(tx), 2) + pow(Double(ty), 2))

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            hiveButton.transform = CGAffineTransform(translationX: tx, y: ty)
        }, completion: completion)
    }

    @objc func buttonPressed(_ hiveButton: HiveButton) {
        openedHive = hiveButton

        guard let item = buttonModels.filter({ $0.title == hiveButton.title(for: UIControlState()) }).first else {
            return
        }

        switch item.content {
        case .webpage:
            performSegue(withIdentifier: "presentContentController", sender: self)
            animateButtonToControllerPoint(hiveButton: hiveButton) { _ in }
        case .templatePicker:
            performSegue(withIdentifier: "openTemplatePicker", sender: self)
            animateButtonToControllerPoint(hiveButton: hiveButton) { _ in }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = buttonModels.filter({ $0.title == self.openedHive?.title(for: .normal) }).first else {
            return
        }

        switch item.content {
        case let .webpage(url):
            guard let destination = segue.destination as? ContentViewController, segue.identifier == "presentContentController" else {
                return
            }
            destination.leftOffset = hexagonWidthForHeight(height/2)
            destination.webView.load(URLRequest(url: url))
            destination.delegate = self
        case .templatePicker:
            guard let destination = segue.destination as? TemplateContainerController, segue.identifier == "openTemplatePicker" else {
                return
            }
            destination.templateDelegate = self
            print("preparing for template picker segue")
        }
  }

}
