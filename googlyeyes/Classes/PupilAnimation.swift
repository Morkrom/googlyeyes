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

class PupilBehaviorManager: NSObject {
    
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
        let gravityBehavior = UIFieldBehavior.linearGravityField(direction: CGVector(dx: 0, dy: 0))
        
        let frictionBehavior = UIFieldBehavior.dragField()
        frictionBehavior.strength = 2
        gravityBehavior.strength = 10

        let ovalFrame = CGRect(origin: CGPoint(x: center.x - travelRadius, y: center.y - travelRadius),
                               size: CGSize(width: travelRadius*2, height: travelRadius*2))
        boundaryBehavior.addBoundary(withIdentifier: "" as NSCopying, for: UIBezierPath(ovalIn: ovalFrame))
        boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
        gravityBehavior.region = UIRegion(radius: travelRadius)
        gravityBehavior.position = center
        gravityBehavior.addItem(googlyEye.pupil)
        frictionBehavior.addItem(googlyEye.pupil)
        
        boundaryBehavior.collisionDelegate = self
        
        animator.addBehavior(frictionBehavior)
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(boundaryBehavior)
        behaviors = ["gravity" : gravityBehavior,
                     "boundary" : boundaryBehavior,
                     "friction": frictionBehavior]
    }
    
    func update(gravity: CMAcceleration, acceleration: CMAcceleration) {
        guard let gravityBehavior = behaviors?["gravity"] as? UIFieldBehavior,
            let friction = behaviors?["friction"] as? UIFieldBehavior else {
                assertionFailure()
            return
        }
        
        let direction: CGVector
        
        if acceleration.z > 0 {
            friction.strength = 0
            let z = acceleration.z
            direction = CGVector(dx: gravity.x * gvM + acceleration.x*accM*(z*z),
                                 dy: -gravity.y * gvM + acceleration.y*accM*(z*z))
            
            gravityBehavior.direction = direction
        } else {
            friction.strength = 1.5
            
            direction = CGVector(dx: gravity.x*gvM+acceleration.x*accM, dy: -gravity.y*gvM+acceleration.y*accM)
                   gravityBehavior.direction = direction
        }
        
        behaviors?["gravity"] = gravityBehavior
        behaviors?["friction"] = friction
        
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
    
    private var isColliding = false
}

// contact w the wall -> set friction strength
// stop -> end friction strength

extension PupilBehaviorManager: UICollisionBehaviorDelegate {
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        isColliding = true
    }

    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        isColliding = true
    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        isColliding = false
    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        isColliding = false
    }
    
}
