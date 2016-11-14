//
//  GooglyEye.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

let coreMotionManager = CMMotionManager()

class GooglyEye: UIView {
  
  static func plasticGrayColor() -> UIColor { return UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)//That shitty 'gray' color for clear plastic
  }
  
  static func cutoutRadius(dimension: CGFloat) -> CGFloat {return dimension/2 * 0.85}
  var cutoutRadius: CGFloat = 0.0

  fileprivate var pupilView = Pupil()
  var pupilDiameterPercentageWidth: CGFloat = 0.3 {
    didSet {
      adjustPupilForNewWidth()
    }
  }
  
  override open class var layerClass: Swift.AnyClass {
    return BevelBase.self
  }
  
  func ringLayerCenterPointForManufacturingDefects() -> CGPoint {
    guard let ringLayer = layer as? BevelBase else {return .zero}
    return ringLayer.startCenter
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = GooglyEye.plasticGrayColor()
    pupilView.backgroundColor = UIColor.black
    addSubview(pupilView)
    
    layer.setNeedsDisplay()
    coreMotionManager.startDeviceMotionUpdates()
    
    displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
    displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    displayLink.frameInterval = 2
    
    animation = GooglyPupilAnimation(googlyEye: self, center: ringLayerCenterPointForManufacturingDefects(), travelRadius: GooglyEye.cutoutRadius(dimension: bounds.width))
  }
  
  override var frame: CGRect {
    didSet {
      cutoutRadius = frame.height/2 * 0.85
      layer.cornerRadius = frame.width/2
      pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
//      floatingRingView.frame = bounds
    }
  }
  
  
  func adjustPupilForNewWidth() {
    if pupilDiameterPercentageWidth > 1.0 {
      pupilDiameterPercentageWidth = 1.0
    } else if pupilDiameterPercentageWidth < 0 {
      pupilDiameterPercentageWidth = 0.01
    }
    pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2,
                             y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2,
                             width: frame.width*pupilDiameterPercentageWidth,
                             height: frame.height*pupilDiameterPercentageWidth)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var animation: GooglyPupilAnimation?
  private var displayLink: CADisplayLink!
  
  func link(link: CADisplayLink) {
    guard let motion = coreMotionManager.deviceMotion,
          let ringLayer = layer as? BevelBase else {return}
    let pitchPercent = CGFloat(motion.attitude.pitch)/CGFloat(1.5)
    let rollPercent = CGFloat(motion.attitude.roll)/CGFloat(1.5)
    animation?.update(gravity: motion.gravity, acceleration: motion.userAcceleration)
    ringLayer.update(pitchPercent:pitchPercent, rollPercent: rollPercent)
  }
}

private class Pupil: UIView {
  
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    get {
      return .ellipse
    }
  }
  
  override var frame: CGRect {
    didSet {
      layer.cornerRadius = frame.width/2
    }
  }
}

private class GooglyPupilAnimation {
    
        private let animator: UIDynamicAnimator
        private var behaviors: [String:UIDynamicBehavior]
        private var behaviorsLocked = false
        private let accM = 13.0
        private let gvM = 2.5
        private let maxGravity = 0.95
        private let maxAcceleration = 0.03
    
        init(googlyEye: GooglyEye, center: CGPoint, travelRadius: CGFloat) {
        
                animator = UIDynamicAnimator(referenceView: googlyEye)
                let boundaryBehavior = UICollisionBehavior(items: [googlyEye.pupilView])
                let gravityBehavior = UIGravityBehavior(items: [googlyEye.pupilView])
        
                let ovalFrame = CGRect(origin: CGPoint(x: center.x - travelRadius, y: center.y - travelRadius),
                                       size: CGSize(width: travelRadius*2, height: travelRadius*2))
            print("ovalFrame: \(ovalFrame)")
                boundaryBehavior.addBoundary(withIdentifier: "" as NSCopying, for: UIBezierPath(ovalIn: ovalFrame))
                boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
                animator.addBehavior(gravityBehavior)
                animator.addBehavior(boundaryBehavior)
                behaviors = ["gravity" : gravityBehavior,
                             "boundary" : boundaryBehavior]
            }
    
        func update(gravity: CMAcceleration, acceleration: CMAcceleration) {
        
                guard let gravityBehavior = behaviors["gravity"] as? UIGravityBehavior else {return}
        
                let direction = CGVector(dx: gravity.x*gvM+acceleration.x*accM, dy: -gravity.y*gvM+acceleration.y*accM)
                gravityBehavior.gravityDirection = direction
                behaviors["gravity"] = gravityBehavior
                if (abs(gravity.z) < maxGravity || (abs(acceleration.x) > maxAcceleration || abs(acceleration.y) > maxAcceleration)) {
                    if behaviorsLocked {
                        if animator.behaviors.count < behaviors.count {
                            
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
      for behavior in behaviors {
        animator.addBehavior(behavior.1)
      }
    }
}
