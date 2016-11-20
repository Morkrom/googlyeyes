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
    
    class func plasticGrayColor() -> UIColor { return GooglyEye.plasticGrayColor(alpha: 1.0) }//That shitty 'gray' color for clear plastic }
    class func plasticGrayColor(alpha: CGFloat) -> UIColor { return UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: alpha) }
    
    static func cutoutRadius(dimension: CGFloat) -> CGFloat {return dimension/2 * 0.85}
    var cutoutRadius: CGFloat = 0.0
    
    fileprivate var pupilView = Pupil()
    var pupilDiameterPercentageWidth: CGFloat = 0.3 {
        didSet {
            adjustPupilForNewWidth()
        }
    }

    let updatedLayer = UpdatingLayer()

    override open class var layerClass: Swift.AnyClass {
        return BevelBase.self
    }
    
    func ringLayerCenterPointForManufacturingDefects() -> CGPoint {
        guard let ringLayer = layer as? BevelBase else {return .zero}
        return ringLayer.startCenter
    }
    
    class BevelBase: CALayer {
        let grayColor = UIColor(colorLiteralRed: 0.83, green: 0.83, blue: 0.8, alpha: 1.0).cgColor
        let stampPercentSizeDifference: CGFloat = 0.1
        let baseStampGradient = CGGradient(colorsSpace: nil, colors: [GooglyEye.plasticGrayColor().cgColor, UIColor.clear.cgColor] as CFArray, locations: nil)
        var startCenter: CGPoint = .zero
        
        override init() {
            super.init()
            contentsScale = UIScreen.main.scale // this one is key
        }
        
        
        override var bounds: CGRect {
            didSet {
                startCenter = CGPoint(x: bounds.width/2 + ((bounds.width/2*0.1) * randomPercent()),
                                      y: bounds.height/2 + ((bounds.height/2*0.1) * randomPercent()))
            }
            
            
        }
        
        func randomPercent() -> CGFloat {
            return CGFloat(Int(arc4random_uniform(100)) - 50) / 100.0
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            ctx.setShouldAntialias(true)
            ctx.setAllowsAntialiasing(true)
            ctx.setBlendMode(.clear)
            ctx.clear(bounds)
            ctx.setBlendMode(.normal)
            ctx.setFillColor(GooglyEye.plasticGrayColor().cgColor)
            let path = CGPath(ellipseIn: bounds, transform: nil)
            ctx.addPath(path)
            ctx.fillPath()

            let radius = GooglyEye.cutoutRadius(dimension: bounds.width)
            ctx.drawRadialGradient(baseStampGradient!,
                                   startCenter: startCenter,
                                   startRadius: radius - (bounds.width*0.05),
                                   endCenter: startCenter,
                                   endRadius: radius + (bounds.width*0.02),
                                   options:  .drawsAfterEndLocation)//.drawsBeforeStartLocation)
            return
        }
    }
    
    class UpdatingLayer: CALayer {
        var endCenter: CGPoint = .zero
        var startCenter: CGPoint = .zero
        let edgeShadowGradient = CGGradient(colorsSpace: nil, colors: [UIColor.clear.cgColor, GooglyEye.plasticGrayColor().cgColor] as CFArray, locations: nil)
        let innerShadowGradient = CGGradient(colorsSpace: nil, colors: [GooglyEye.plasticGrayColor(alpha: 0.2).cgColor, UIColor.clear.cgColor] as CFArray, locations: nil)

        
        func update(pitchPercent: CGFloat, rollPercent: CGFloat) {
            let abs = fabs(Double(pitchPercent))
            if abs > 1.0 || abs < 0.0 || abs > 1.0 || abs < 0.0 {
                return
            }
            
            endCenter = CGPoint(x: startCenter.x + (rollPercent*10.0), y: startCenter.y + (pitchPercent*10.0))
            setNeedsDisplay()
        }
        
        override init() {
            super.init()
            contentsScale = UIScreen.main.scale // this one is key
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            let radius = GooglyEye.cutoutRadius(dimension: bounds.width)
            ctx.drawRadialGradient(edgeShadowGradient!,
                                   startCenter: endCenter,
                                   startRadius: radius - (bounds.width*0.1),
                                   endCenter: startCenter,
                                   endRadius: radius + (bounds.width*0.035),
                                   options:  .drawsBeforeStartLocation)
            
            ctx.drawRadialGradient(innerShadowGradient!, startCenter: endCenter, startRadius: 1, endCenter: endCenter, endRadius: radius*0.666, options: .drawsBeforeStartLocation)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // create gradient upper layer with 'adjustment'
        guard let base = layer as? BevelBase else {return}
        pupilView.backgroundColor = UIColor.black
        
        layer.setNeedsDisplay()
        coreMotionManager.startDeviceMotionUpdates()
        
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        displayLink.frameInterval = 2

        addSubview(pupilView)

        animation = GooglyPupilAnimation(googlyEye: self, center: ringLayerCenterPointForManufacturingDefects(), travelRadius: GooglyEye.cutoutRadius(dimension: bounds.width))
        
        updatedLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        base.addSublayer(updatedLayer)
        
    }
    
    override var frame: CGRect {
        didSet {
            cutoutRadius = frame.height/2 * 0.85
            layer.cornerRadius = frame.width/2
            pupilView.frame = CGRect(x: (frame.width - frame.width*pupilDiameterPercentageWidth)/2, y: (frame.height - frame.width*pupilDiameterPercentageWidth)/2, width: frame.width*pupilDiameterPercentageWidth, height: frame.height*pupilDiameterPercentageWidth)
            updatedLayer.bounds = CGRect(x: -bounds.width/2, y: -bounds.height/2, width: bounds.width, height: bounds.height)
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
        guard let motion = coreMotionManager.deviceMotion else {return}
        let pitchPercent = CGFloat(motion.attitude.pitch)/CGFloat(1.5)
        let rollPercent = CGFloat(motion.attitude.roll)/CGFloat(1.5)
        animation?.update(gravity: motion.gravity, acceleration: motion.userAcceleration)
        updatedLayer.update(pitchPercent:pitchPercent, rollPercent: rollPercent)
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
