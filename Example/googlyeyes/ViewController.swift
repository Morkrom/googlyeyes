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
      let eysView = GooglyEyeView(frame: CGRect(x: 30, y: 100, width: 300, height: 200))
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
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.whiteColor()
    pupilView.backgroundColor = UIColor.blackColor()
    addSubview(pupilView)
  }

  override var frame: CGRect {
    didSet {
      pupilView.frame = CGRect(x: frame.width/2 - frame.width/4, y: frame.height/2 - frame.width/4, width: frame.width/2, height: frame.height/2)
      layer.cornerRadius = frame.width/2
    }
  }
  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    pupilView.frame = CGRect(x: frame.width/2 - frame.width/4, y: frame.height/2 - frame.width/4, width: frame.width/2, height: frame.height/2)
//    layer.cornerRadius = frame.width/2
//  }
  
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

class GooglyEyeView: UIView {
  static let Left = 1
  static let Right = 2
  var eyeDiameter: CGFloat = 20
  
  let leftEye = GooglyEye()
  let rightEye = GooglyEye()
  
  var animators = [Int: UIDynamicAnimator]()
  var gravityBehaviors = [Int: UIGravityBehavior]()
  var displayLink: CADisplayLink!
  
  func link(link: CADisplayLink) {
    guard let gravity = coreMotionManager.deviceMotion?.gravity else {return}
    let gravityDirection = CGVector(dx: gravity.x, dy: -(gravity.y))
    gravityBehaviors[GooglyEyeView.Left]?.gravityDirection = gravityDirection
    gravityBehaviors[GooglyEyeView.Right]?.gravityDirection = gravityDirection
    
  }
  
  func eyesDiameter() -> CGFloat {
    return frame.width > frame.height*2 ? frame.height : frame.width/2
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
    //backgroundColor = UIColor.clearColor()
    eyeDiameter = eyesDiameter()
      
    coreMotionManager.startDeviceMotionUpdates()
    
    displayLink = CADisplayLink(target: self, selector: #selector(GooglyEyeView.link(_:)))
    displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    displayLink.frameInterval = 1
    
    addSubview(leftEye)
    addSubview(rightEye)
    
    frameUp()
    
    addGooglyBehavior(leftEye, key: GooglyEyeView.Left)
    addGooglyBehavior(rightEye, key: GooglyEyeView.Right)
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
  
  func addGooglyBehavior(eye: GooglyEye, key: Int) {
    let animator = UIDynamicAnimator(referenceView: eye)
    let gravityBehavior = UIGravityBehavior(items: [eye.pupilView])
    let boundaryBehavior = UICollisionBehavior(items: [eye.pupilView])
    
    boundaryBehavior.addBoundaryWithIdentifier("bezier", forPath: UIBezierPath(ovalInRect: eye.bounds))
    boundaryBehavior.translatesReferenceBoundsIntoBoundary = true
    animator.addBehavior(gravityBehavior)
    animator.addBehavior(boundaryBehavior)
    
    animators[key] = animator
    gravityBehaviors[key] = gravityBehavior

  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

