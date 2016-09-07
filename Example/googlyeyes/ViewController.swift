//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit
import CoreMotion

let coreMotionManager = CMMotionManager()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      let eysView = GooglyEyeView(frame: CGRect(x: 30, y: 100, width: 300, height: 100))
      view.addSubview(eysView)
      view.backgroundColor = UIColor.blackColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// 6 add sheen gradient view corresponding to gravity direction
// 1 add sizing + nose gap for eyes view based on difference between width and height... you'll figure it out, you clever boy.
// 3 support for autolayout
// 5 isLazy <- random difference
// 4 add friction if boundaries are met
// 2 add shaking

//determine and add some tests

class GooglyEye: UIView {
  var pupilView = Pupil()
  var pupilDiameterPercentageWidth: CGFloat = 0.66 {
    didSet {
      if pupilDiameterPercentageWidth > 1.0 {
        pupilDiameterPercentageWidth = 1.0
      } else if pupilDiameterPercentageWidth < 0 {
        pupilDiameterPercentageWidth = 0.01
      }

      pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()
    pupilView.backgroundColor = UIColor.blackColor()
    addSubview(pupilView)
  }

  override var frame: CGRect {
    didSet {
      layer.cornerRadius = frame.width/2
      pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class Pupil: UIView {
  
  @available(iOS 9.0, *) // w/o iOS 9 you're screwed, you shouldn't be under this anyway.
  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    get {
      return .Ellipse
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
  
  let leftEye = GooglyEye()
  let rightEye = GooglyEye()
  
  var animators = [UIDynamicAnimator]()
  var gravityBehaviors = [String:UIGravityBehavior]()
  var displayLink: CADisplayLink!
  
  var collisionBehaviorForBoundaryIdentifierShouldSlowItsRoll = [String:Bool]()
  var frictionTiming = [String:CFTimeInterval]()
  var collisionEndedCountNoiseBuffer = [String:Int]()
  
  func link(link: CADisplayLink) {
    guard let gravity = coreMotionManager.deviceMotion?.gravity else {return}
    guard let acceleration = coreMotionManager.deviceMotion?.userAcceleration else {return}
    
    var count = 0
    for behavior in gravityBehaviors {
      //engage static when too close to any edge
      //disengage static when acceleration is .. up there
      //let gravity have its way w/o static
      
      
      
      /*
       staticEngaged = abs(acceleration.x*acceleration.y) > staticEngagementThreshold
       
       if (staticEngaged) {
        //previousDirection may be randomized on an arc for static being engaged
        //accelerationDirection = previousDirection
       } else {
        
       }
       
       
       */
      let engageStatic = collisionBehaviorForBoundaryIdentifierShouldSlowItsRoll[behavior.0]
      let accelerationDirection = CGVector(dx: engageStatic == true ? -(acceleration.x*10 + gravity.x) : (acceleration.x*10 + gravity.x), dy: engageStatic == true ? (acceleration.y*10 + gravity.y) : -(acceleration.y*10 + gravity.y))
      behavior.1.gravityDirection = accelerationDirection
      count += 1
    }
  }
  
  func eyesDiameter() -> CGFloat {
    return frame.width > frame.height*2 ? frame.height : frame.width/2
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
    eyeDiameter = eyesDiameter()
      
    coreMotionManager.startDeviceMotionUpdates()
    
    displayLink = CADisplayLink(target: self, selector: #selector(GooglyEyeView.link(_:)))
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    displayLink.frameInterval = 2
    
    addSubview(leftEye)
    addSubview(rightEye)
    
    frameUp()
    
    addGooglyBehavior(leftEye, key: "left")
    addGooglyBehavior(rightEye, key: "right")
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
  }
  
  func addGooglyBehavior(eye: GooglyEye, key: String) {
    let animator = UIDynamicAnimator(referenceView: eye)
    let gravityBehavior = UIGravityBehavior(items: [eye.pupilView])
    let boundaryBehavior = UICollisionBehavior(items: [eye.pupilView])
    
    
    boundaryBehavior.collisionDelegate = self
    boundaryBehavior.addBoundaryWithIdentifier(key, forPath: UIBezierPath(ovalInRect: eye.bounds))
    boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
    animator.addBehavior(gravityBehavior)
    animator.addBehavior(boundaryBehavior)
    
    animators.append(animator)
    gravityBehaviors[key] = gravityBehavior
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func engageStatic(eyeball: String) {
    let begin = randomNanoSecondsTime(0)
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, begin), dispatch_get_main_queue()) { [weak self] in
      self?.collisionBehaviorForBoundaryIdentifierShouldSlowItsRoll[eyeball] = true
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, begin + randomNanoSecondsTime(5.0)), dispatch_get_main_queue()) { [weak self] in
      self?.collisionBehaviorForBoundaryIdentifierShouldSlowItsRoll[eyeball] = false
    }
  }
  
  func randomNanoSecondsTime(ceiling: Float32) -> Int64 {
    return Int64(Float(NSEC_PER_SEC) * Float32(arc4random_uniform(100)) * ceiling)
  }
  
  func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
    guard let eyeballIdentifier = identifier as? String else {return}
    if item.center.y < eyeDiameter/2 {
      engageStatic(eyeballIdentifier)
    }
    else {
      collisionBehaviorForBoundaryIdentifierShouldSlowItsRoll[eyeballIdentifier] = false
    }
  }
  
}

