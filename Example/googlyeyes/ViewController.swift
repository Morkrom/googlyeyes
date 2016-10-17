//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit
import CoreMotion
import QuartzCore

let coreMotionManager = CMMotionManager()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      let eysView = GooglyEyeView(frame: CGRect(x: 30, y: 100, width: 300, height: 100))
      view.addSubview(eysView)
      view.backgroundColor = UIColor.black
      let eye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
      view.addSubview(eye)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//plastic ring "stamping" 
//  gray plastic "sheen", dark gray thin gradiated edge 
//  - 5-10% of width is stamp, random distance to edge of eye ball - include new actual center offset and boundary dimension for pupil
// static electricity area rub - (save points in a decaying rubbing buffer from a pan gesture)
// 6 add sheen gradient view corresponding to gravity direction
// 3 support for autolayout

/*
 - STATIC -
   pan gesture recognizer:
   - the CGPoint
   - have a points list with [point, media time]
*/

extension UIView {
  
  // motion effects, yo...
  internal func addEffect(horizontalTotalRelativeRange: CGFloat, verticalTotalRelativeRange: CGFloat) {

    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    horizontalMotionEffect.minimumRelativeValue = -horizontalTotalRelativeRange/2
    horizontalMotionEffect.maximumRelativeValue = horizontalTotalRelativeRange/2
    addMotionEffect(horizontalMotionEffect)
    
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    verticalMotionEffect.minimumRelativeValue = -verticalTotalRelativeRange/2
    verticalMotionEffect.maximumRelativeValue = verticalTotalRelativeRange/2
    addMotionEffect(verticalMotionEffect)
  }
}

class RingLayer: CALayer {
  
  override init() {
    super.init()
    backgroundColor = UIColor.clear.cgColor
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(in ctx: CGContext) {
    
    ctx.setBlendMode(.clear)

    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    ctx.clear(bounds)
    ctx.addRect(bounds)
    ctx.setFillColor(red: 1, green: 1, blue: 0.5, alpha: 1)

    ctx.clip()
    
    let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    let outerRadius = bounds.width/2 * 0.85 // dyou see what's going on here?? do you?
    let envelopingEllipseRadius = outerRadius + outerRadius*0.01
    ctx.addEllipse(in: CGRect(x: center.x - envelopingEllipseRadius, y:center.y - envelopingEllipseRadius , width: envelopingEllipseRadius*2, height: envelopingEllipseRadius*2))

//    ctx.setFillColor(red: 1, green: 1, blue: 0.5, alpha: 1)
//    ctx.fill(bounds)

    ctx.clip()
    
    let baseStampGradient = CGGradient(colorsSpace: nil,
                                       colors: [UIColor.clear.cgColor, UIColor.lightGray.cgColor] as CFArray,
                                       locations: nil)
    
    ctx.drawRadialGradient(baseStampGradient!,
                           startCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                           startRadius: outerRadius * 0.9,
                           endCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                           endRadius: outerRadius,
                           options: .drawsAfterEndLocation)

    
//    ctx.setFillColor(red: 1, green: 1, blue: 0.5, alpha: 1)
//    ctx.fill(bounds)
  }
}

class FloatingRingLayer: CALayer {
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(in ctx: CGContext) {

    //ctx.setBlendMode(.clear)
 
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    ctx.clear(bounds)
    ctx.addRect(bounds)
    ctx.clip()
    
    let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    let outerRadius = bounds.width/2 * 0.85 // dyou see what's going on here?? do you?
    let envelopingEllipseRadius = outerRadius + outerRadius*0.01
    
    ctx.addEllipse(in: CGRect(x: center.x - envelopingEllipseRadius, y:center.y - envelopingEllipseRadius , width: envelopingEllipseRadius*2, height: envelopingEllipseRadius*2))

    //    ctx.setFillColor(red: 1, green: 1, blue: 0.5, alpha: 1)
    //    ctx.fill(bounds)
    
    ctx.clip()
    ctx.fill(bounds)
    ctx.clear(bounds)
    let baseStampGradient = CGGradient(colorsSpace: nil,
                                       colors: [UIColor.clear.cgColor, UIColor.lightGray.cgColor] as CFArray,
                                       locations: nil)
    
    ctx.drawRadialGradient(baseStampGradient!,
                           startCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                           startRadius: outerRadius * 0.9,
                           endCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                           endRadius: outerRadius,
                           options: .drawsBeforeStartLocation) // <- This could be extended as a 'cone' depending on device dynamics
  //drawsAfterEndLocation
    
  }
}

class FloatingRingView: UIView {
  
  override open class var layerClass: Swift.AnyClass {
    return FloatingRingLayer.self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var frame: CGRect {
    didSet {
      layer.setNeedsDisplay()
    }
  }
}

class GooglyEye: UIView {
  static var defaultPupilDiameterPercentageWidth: CGFloat = 0.3//0.66
  var pupilView = Pupil()
  let floatingRingView = FloatingRingView(frame: .zero)
  var pupilDiameterPercentageWidth: CGFloat = GooglyEye.defaultPupilDiameterPercentageWidth {
    didSet {
      adjustPupilForNewWidth()
    }
  }
  
//  override open class var layerClass: Swift.AnyClass {
//    return RingLayer.self
//  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = GooglyEyeAntiPattern.plasticGrayColor()
    pupilView.backgroundColor = UIColor.black
    addSubview(pupilView)
    
    floatingRingView.backgroundColor = UIColor.clear
    addSubview(floatingRingView)
    floatingRingView.addEffect(horizontalTotalRelativeRange: frame.width*0.1, verticalTotalRelativeRange: frame.height*0.1)
    layer.setNeedsDisplay()
    floatingRingView.frame = bounds
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

class Pupil: UIView {
  
  @available(iOS 9.0, *) // w/o iOS 9 you're screwed, you shouldn't be under this anyway.
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
}
