//
//  Animations.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

private protocol AnimationDelegate: class {
    func animationDidFinish(_ animation: Animation)
}

enum AnimationState {
    case ready
    case animating(identifier: AnimationIdentifier)
}

struct AnimationConfiguration {
    let startValue: CGFloat
    let endValue: CGFloat
    let duration: CFTimeInterval
    
    var delta: CGFloat {
        return endValue - startValue
    }
}


typealias AnimationIdentifier = UInt

private let accessorQueue = DispatchQueue(label: "animation_accessor_queue", attributes: [])
private var __identifier : AnimationIdentifier = 0
private func nextIdentifier()-> AnimationIdentifier {
    var identifier: AnimationIdentifier!
    accessorQueue.sync {
        identifier = (__identifier % AnimationIdentifier.max) + 1
        __identifier = identifier
    }
    
    return identifier
}

// MARK: Animation

private class Animation {
    let identifier: AnimationIdentifier
    var views = Set<HexagonView>()
    weak var delegate: AnimationDelegate?
    
    // values
    let start: CGFloat
    let delta: CGFloat
    var currentValue: CGFloat = 0
    
    // time
    let endTime: CFTimeInterval
    var currentTime: CFTimeInterval = 0
    
    required init (views: [HexagonView], configuration:AnimationConfiguration) {
        self.identifier = nextIdentifier()
        self.views = Set(views)
        self.start = configuration.startValue
        self.delta = configuration.delta
        self.endTime = configuration.duration
        
        // set state to animating
        views.forEach { $0.animationState = .animating(identifier: self.identifier) }
    }
    
    func removeView(_ view: HexagonView) {
        view.animationState = .ready
        views.remove(view)
        if views.count == 0 {
            delegate?.animationDidFinish(self)
        }
    }
    
    func increaseTime(_ increment: CFTimeInterval) {
        currentTime += increment
        
        // clip to endtime
        if currentTime > endTime {
            currentTime = endTime
        }
        
        // calculate current value
        let factor = CGFloat(currentTime / endTime)
        currentValue = start + delta * factor
        
        updateViews()
        updateAniamationState()
    }
    
    // override in subclasses to update the views with the current value
    func updateViews() {}
    
    func updateAniamationState() {
        // finish if end time is reached
        if currentTime >= endTime {
            // reset animation state to Ready
            views.forEach { $0.animationState = .ready }
            // inform delegate
            delegate?.animationDidFinish(self)
        }
    }
}

private final class FadeAnimation: Animation {
    override func updateViews() {
        views.forEach { $0.alpha = currentValue }
    }
}

// MARK: Animator
class Animator {
    fileprivate static let animator = Animator()
    fileprivate var displayLink: CADisplayLink!
    fileprivate var animations: [AnimationIdentifier : Animation] = [:]
    fileprivate var lastDrawTime: CFTimeInterval = 0
    
    init () {
        displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(tick))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    // MARK: Add
    static func addAnimationForViews(_ views: [HexagonView], configuration: AnimationConfiguration) {
        // collect views ready for animation
        var ready: [HexagonView] = []
        views.forEach { view in
            switch view.animationState {
            case .ready:
                ready.append(view)
            case .animating(let identifier):
                // pick up from current animation value when already .Animating. creates separate animations per view
                if let existingAnimation = animator.animations[identifier] {
                    // remove view from old animation
                    existingAnimation.removeView(view)
                    // add to new animation starting from current value
                    let config = AnimationConfiguration(startValue: existingAnimation.currentValue, endValue: configuration.endValue, duration: configuration.duration)
                    let newAnimation = FadeAnimation(views: [view], configuration: config)
                    animator.addAnimation(newAnimation)
                }
                else {
                    assertionFailure("Should not occur")
                    view.animationState = .ready
                    ready.append(view)
                }
            }
        }
        // Start animating the views with animation state ready together in a single animation
        if ready.count > 0 {
            let animation = FadeAnimation(views: ready, configuration: configuration)
            animator.addAnimation(animation)
        }
    }
    
    fileprivate func addAnimation(_ animation: Animation) {
        animation.delegate = self
        animations[animation.identifier] = animation
    }
    
    // MARK: Display link
    @objc func tick(_ displayLink: CADisplayLink) {
        if lastDrawTime == 0 {
            lastDrawTime = displayLink.timestamp
        }
        let duration = displayLink.timestamp - lastDrawTime
        
        animations.forEach { (_, animation) in
            animation.increaseTime(duration)
        }
        
        lastDrawTime = displayLink.timestamp
    }
}

// MARK: AnimationDelegate
extension Animator: AnimationDelegate {
    fileprivate func animationDidFinish(_ animation: Animation) {
        animations[animation.identifier] = nil
    }
}
