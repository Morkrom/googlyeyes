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
  static var defaultPupilDiameterPercentageWidth: CGFloat = 0.3
  fileprivate var pupilView = Pupil()
  let floatingRingView = FloatingRingView(frame: .zero)
  var pupilDiameterPercentageWidth: CGFloat = GooglyEye.defaultPupilDiameterPercentageWidth {
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
    
    backgroundColor = GooglyEyeAntiPattern.plasticGrayColor()
    pupilView.backgroundColor = UIColor.black
    addSubview(pupilView)
    
    floatingRingView.backgroundColor = UIColor.clear
    
    let center = ringLayerCenterPointForManufacturingDefects()
    let dimension = layer.bounds.width
    
    floatingRingView.frame = CGRect(origin: CGPoint(x: center.x - dimension/2, y: center.y - dimension/2), size: CGSize(width: dimension, height: dimension))
    addSubview(floatingRingView)
    floatingRingView.addEffect(horizontalTotalRelativeRange: frame.width*0.25, verticalTotalRelativeRange: frame.height*0.25)
    layer.setNeedsDisplay()
  }
  
  override var frame: CGRect {
    didSet {
      layer.cornerRadius = frame.width/2
      pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
      floatingRingView.frame = bounds
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

class GooglyEyeView: UIView, UICollisionBehaviorDelegate {
  static let Left = 1
  static let Right = 2
  var eyeDiameter: CGFloat = 20
  var pupilDiameterPercentageWidth: CGFloat = GooglyEye.defaultPupilDiameterPercentageWidth
  
  let leftEye = GooglyEye()
  let rightEye = GooglyEye()
  
  private var animations = [String:Animation]()
  var displayLink: CADisplayLink!
  
  var beforeThereWasStaticReferenceAcceleration = CGVector()
  
  private class Animation {
    
    let animator: UIDynamicAnimator
    var behaviors: [String:UIDynamicBehavior]
    let eye: GooglyEye
    private var behaviorsLocked = false
    
    func resetBehaviors() {
      if animator.behaviors.count < behaviors.count {
        animator.removeAllBehaviors()
        for behavior in behaviors {
          animator.addBehavior(behavior.1)
        }
      }
    }
    
    init(eye: GooglyEye) {
      
      self.eye = eye
      animator = UIDynamicAnimator(referenceView: eye)
      
      let boundaryBehavior = UICollisionBehavior(items: [eye.pupilView])
      let gravityBehavior = UIGravityBehavior(items: [eye.pupilView])
      
      boundaryBehavior.addBoundary(withIdentifier: "" as NSCopying, for: UIBezierPath(ovalIn: eye.bounds))
      boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
      animator.addBehavior(gravityBehavior)
      animator.addBehavior(boundaryBehavior)
      print(animator.behaviors.count)
      behaviors = ["gravity" : gravityBehavior,
                   "boundary" : boundaryBehavior]
    }
    
    func update(gravity: CMAcceleration, acceleration: CMAcceleration) {
      
      let accM = 13.0
      let gvM = 2.5
      let maxGravity = 0.95
      let maxAcceleration = 0.03
      
      if let gravityBehavior = behaviors["gravity"] as? UIGravityBehavior {
        
        let direction = CGVector(dx: gravity.x*gvM+acceleration.x*accM, dy: -gravity.y*gvM+acceleration.y*accM)
        gravityBehavior.gravityDirection = direction
        behaviors["gravity"] = gravityBehavior
        if (abs(gravity.z) < maxGravity || (abs(acceleration.x) > maxAcceleration || abs(acceleration.y) > maxAcceleration)) {
          if behaviorsLocked {
            self.resetBehaviors()
          }
          behaviorsLocked = false
        } else {
          animator.removeAllBehaviors()
          behaviorsLocked = true
        }
        
      } else {
        print("no gravity behavior")
      }
    }
  }
  
  func link(link: CADisplayLink) {
    guard let gravity = coreMotionManager.deviceMotion?.gravity else {return}
    guard let acceleration = coreMotionManager.deviceMotion?.userAcceleration else {return}
    //print("z: \(gravity.z)")
    
    for animation in animations {
      animation.1.update(gravity: gravity, acceleration: acceleration)
      
    }
  }
  
  func eyesDiameter() -> CGFloat {
    return frame.width > frame.height*2 ? frame.height : frame.width/2
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.green.withAlphaComponent(0.5)
    eyeDiameter = eyesDiameter()
    coreMotionManager.startDeviceMotionUpdates()
    
    displayLink = CADisplayLink(target: self, selector: #selector(GooglyEyeView.link))
    displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    displayLink.frameInterval = 2
    
    addSubview(leftEye)
    addSubview(rightEye)
    
    frameUp()
    
    animations["left"] = Animation(eye: leftEye)
    animations["right"] = Animation(eye: rightEye)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    frameUp()
  }
  
  func frameUp() {
    let size = CGSize(width: eyeDiameter, height: eyeDiameter)
    let y = (frame.height - eyeDiameter)/2
    leftEye.frame = CGRect(origin: CGPoint(x:0, y:y), size: size)
    rightEye.frame = CGRect(origin: CGPoint(x:frame.width - eyeDiameter, y:y), size: size)
    
    for eye in [leftEye, rightEye] {
      eye.pupilDiameterPercentageWidth = self.pupilDiameterPercentageWidth
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


class GooglyEyeAntiPattern {
  
  static func plasticGrayColor() -> UIColor { return UIColor(colorLiteralRed: 0.99, green: 0.99, blue: 0.99, alpha: 1)//That shitty 'gray' color for clear plastic
  }
  
  static func cutoutRadius(dimension: CGFloat) -> CGFloat {return dimension/2 * 0.85}
}
