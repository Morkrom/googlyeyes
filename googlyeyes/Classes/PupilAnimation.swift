//
//  PupilAnimation.swift
//  googlyeyes
//
//  Created by Michael Mork on 11/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

class PupilBehaviorManager {
    
    let animator: UIDynamicAnimator
    var behaviors: [String:UIDynamicBehavior]?
    private var behaviorsLocked = false
    private let accM = 13.0
    private let gvM = 2.5
    private let maxGravity = 0.95
    private let maxAcceleration = 0.03
    
    init(googlyEye: GooglyEye, center: CGPoint, travelRadius: CGFloat) {
        MotionProvider.shared.motionManager().startDeviceMotionUpdates()
        animator = UIDynamicAnimator(referenceView: googlyEye)
    }
    
    func updateBehaviors(googlyEye: GooglyEye, center: CGPoint, travelRadius: CGFloat) {
        animator.removeAllBehaviors()
        setup(googlyEye: googlyEye, center: center, travelRadius: travelRadius)
    }
    
    private func setup(googlyEye: GooglyEye, center: CGPoint, travelRadius: CGFloat) {
        let boundaryBehavior = UICollisionBehavior(items: [googlyEye.pupil])
        let gravityBehavior = UIGravityBehavior(items: [googlyEye.pupil])
        let ovalFrame = CGRect(origin: CGPoint(x: center.x - travelRadius, y: center.y - travelRadius),
                               size: CGSize(width: travelRadius*2, height: travelRadius*2))
        boundaryBehavior.addBoundary(withIdentifier: "" as NSCopying, for: UIBezierPath(ovalIn: ovalFrame))
        boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(boundaryBehavior)
        behaviors = ["gravity" : gravityBehavior,
                     "boundary" : boundaryBehavior]
    }
    
    func update(gravity: CMAcceleration, acceleration: CMAcceleration) {
        guard let gravityBehavior = behaviors?["gravity"] as? UIGravityBehavior else {return}
        let direction = CGVector(dx: gravity.x*gvM+acceleration.x*accM, dy: -gravity.y*gvM+acceleration.y*accM)
        gravityBehavior.gravityDirection = direction
        behaviors?["gravity"] = gravityBehavior
        if (abs(gravity.z) < maxGravity || (abs(acceleration.x) > maxAcceleration || abs(acceleration.y) > maxAcceleration)) {
            if behaviorsLocked {
                if animator.behaviors.count < behaviors?.count ?? 0 {
                    resetBehaviors()
                }
            }
            behaviorsLocked = false
        } else {
            animator.removeAllBehaviors()
            behaviorsLocked = true
        }
    }
    
    private func resetBehaviors() {
        animator.removeAllBehaviors()
        for behavior in behaviors ?? [String: UIDynamicBehavior]() {
            animator.addBehavior(behavior.1)
        }
    }
}
