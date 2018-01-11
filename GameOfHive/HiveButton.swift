//
//  HiveButton.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 02-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

enum HiveButtonStyle: CGFloat {
    case big = 16
    case small = 14
}

@IBDesignable
class HiveButton: UIButton {

    // MARK: Lifecycle
    let backgroundView = UIView()
    
    var style: HiveButtonStyle = .big {
        didSet {
            titleLabel?.numberOfLines = 0
            titleLabel?.textAlignment = .center
            titleLabel?.font = UIFont(name: "Raleway-Medium", size: style.rawValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func prepareForInterfaceBuilder() {
        initialize()
    }

    override var frame: CGRect {
        didSet {
            updateLayers()
        }
    }

    fileprivate func initialize() {
        setNeedsLayout()
        layoutIfNeeded()

        titleLabel?.font = UIFont(name: "Raleway-Medium", size: style.rawValue)
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(UIColor.darkAmberColor, for: UIControlState())
        tintColor = UIColor.darkAmberColor

        insertSubview(backgroundView, belowSubview: titleLabel!)
        backgroundView.constrainToView(self)
        backgroundView.backgroundColor = UIColor.menuButtonBackgroundColor
        backgroundView.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
    }

    override func draw(_ rect: CGRect) {
        updateLayers()
    }

    func updateLayers() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = hexagonPath(backgroundView.frame.size)
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor.darkAmberColor.cgColor
        borderLayer.lineWidth = style == HiveButtonStyle.big ? 5 : 2
        borderLayer.fillColor = UIColor.clear.cgColor
        backgroundView.layer.mask = maskLayer
        backgroundView.layer.addSublayer(borderLayer)
    }
}
