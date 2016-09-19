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
      view.backgroundColor = UIColor.black
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
  static var defaultPupilDiameterPercentageWidth: CGFloat = 0.66
  var pupilView = Pupil()
  var pupilDiameterPercentageWidth: CGFloat = GooglyEye.defaultPupilDiameterPercentageWidth {
    didSet {
      //print("diametprecrewidth: \(pupilDiameterPercentageWidth)")
      if pupilDiameterPercentageWidth > 1.0 {
        pupilDiameterPercentageWidth = 1.0
      } else if pupilDiameterPercentageWidth < 0 {
        pupilDiameterPercentageWidth = 0.01
      }
      //print("diametprecepwdith: \(pupilDiameterPercentageWidth)")
      pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    pupilView.backgroundColor = UIColor.black
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
  
  class Animation {
    let animator: UIDynamicAnimator
    var behaviors: [String:UIDynamicBehavior]
    let eye: GooglyEye
    private var behaviorsLocked = false
    
    func resetBehaviors() {
      print(" \n ---- \n animator.behaviors count: \(animator.behaviors.count), behaviors count:\(behaviors.count) \n ---- \n ")
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
      
      if let gravityBehavior = behaviors["gravity"] as? UIGravityBehavior {
      
        let direction = CGVector(dx: gravity.x*gvM+acceleration.x*accM, dy: -gravity.y*gvM+acceleration.y*accM)
        gravityBehavior.gravityDirection = direction
        behaviors["gravity"] = gravityBehavior
        if (abs(gravity.z) < 0.95) {
          //enable gravity behaviors
          
          if behaviorsLocked {
            self.resetBehaviors()
//            print("restart")
          }
          
          behaviorsLocked = false
          
        } else {
//          print("disable: \(abs(gravity.z))")
//          //disable gravity behaviors
//          print("animator count: \(animator.behaviors.count)")
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
    
    pupilDiameterPercentageWidth = 0.3
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

