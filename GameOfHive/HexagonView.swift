//
//  HiveView.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

protocol HexagonViewDelegate: class {
    func userDidUpateCell(_ cell: HexagonView)
}

func hexagonPath(_ size: CGSize, lineWidth: CGFloat = 0) -> CGPath {
        let height = size.height
        let width = size.width
        
        // points numbered like this:
    	//
        //     1
        //  6     2
    	//
        //  5     3
        //	   4
        
        let topBottomOffset = (sqrt((3 * lineWidth * lineWidth) / 4))
        
        let p1 = CGPoint(x: width / 2.0, y: topBottomOffset)
        let p2 = CGPoint(x: width - (lineWidth / 2), y: height / 4)
        let p3 = CGPoint(x: p2.x, y: p2.y * 3)
        let p4 = CGPoint(x: p1.x, y: height - topBottomOffset)
        let p5 = CGPoint(x: lineWidth / 2, y: p3.y)
        let p6 = CGPoint(x: p5.x, y: p2.y)
        
    
        
        let path = CGMutablePath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.addLine(to: p6)
    	path.closeSubpath()
    
        return path
}

class HexagonView: UIView {
    static let path: CGPath = hexagonPath(cellSize, lineWidth: lineWidth)

    static let fillColor = UIColor.lightAmberColor
    
    static let aliveAlpha: CGFloat = 1
    static let deadAlpha: CGFloat = 0.15
    
    var coordinate = Coordinate(row: NSNotFound, column: NSNotFound)
    var alive: Bool = false

    var animationState: AnimationState = .ready
    
    weak var hexagonViewDelegate: HexagonViewDelegate?
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = HexagonView.deadAlpha
        self.backgroundColor = UIColor.clear
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first, touches.count == 1 && HexagonView.path.contains(touch.location(in: self)) else {
            return
    }
        // invert alive
        self.alive = !self.alive
        // inform delegate
        hexagonViewDelegate?.userDidUpateCell(self)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return HexagonView.path.contains(point)
    }

    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        context?.setFillColor(HexagonView.fillColor.cgColor)
        context?.addPath(HexagonView.path)
        context?.fillPath()
    }
}
