//
//  GooglyEye.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class GooglyEye: UIView {
    
    var pupilDiameterPercentageWidth: CGFloat = 0.62 {
        didSet {
            updateDimensions()
        }
    }
    
    var pupil = Pupil()
    
    private class func grayColor() -> UIColor { return GooglyEye.paperGray(alpha: 1.0) }
    private class func paperGray(alpha: CGFloat) -> UIColor {return
        UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: alpha)}
    
    private class func cutoutRadius(dimension: CGFloat) -> CGFloat {return dimension/2 * 0.97}
    
    private class func diameterFromFrame(rectSize: CGSize) -> CGFloat {return rectSize.width > rectSize.height ? rectSize.height : rectSize.width}
    
    private var displayLink: CADisplayLink!
    private var animation: PupilBehaviorManager?
    private var diameter: CGFloat = 0
    private var orientation = UIApplication.shared.statusBarOrientation
    private var baseCutout = Sclera()
    private let innerStamp = HeatStamp()
  
    class func autoLayout() -> GooglyEye {
    let gEye = GooglyEye(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        gEye.translatesAutoresizingMaskIntoConstraints = false
        return gEye
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link)) //initialization
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default) //properties
        displayLink.frameInterval = 2
        addSubview(pupil)
        layer.addSublayer(baseCutout)
        layer.addSublayer(innerStamp)
        layer.insertSublayer(pupil.layer, below: innerStamp)
        
        if frame.size != .zero {
            animation = PupilBehaviorManager(googlyEye: self, center: baseCutout.startCenter, travelRadius: diameter)
        }
        
        updateDimensions()
    }

    private func updateDimensions() {
        guard animation != nil else {
            return
        }
        
        diameter = GooglyEye.diameterFromFrame(rectSize: frame.size)
        
        baseCutout.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        innerStamp.startCenter = baseCutout.startCenter
        innerStamp.frame = baseCutout.bounds
        if orientation == UIApplication.shared.statusBarOrientation { // Avoid changing the pupil frame if there's a status bar animation happening - doing so compromises an otherwise concentric pupil.
            adjustPupilForNewWidth()
            pupil.layer.setNeedsDisplay()
        }
        
        innerStamp.update()

        baseCutout.setNeedsDisplay()
        innerStamp.setNeedsDisplay()
        animation?.updateBehaviors(googlyEye: self, center: baseCutout.startCenter, travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
    }
    
    private func adjustPupilForNewWidth() {
        if pupilDiameterPercentageWidth > 1.0 {
            pupilDiameterPercentageWidth = 1.0
        } else if pupilDiameterPercentageWidth < 0 {
            pupilDiameterPercentageWidth = 0.01
        }
        
        pupil.frame = CGRect(x: pupil.frame.minX - (pupil.frame.width - diameter*pupilDiameterPercentageWidth)/2, y: pupil.frame.minY - (pupil.frame.height - diameter*pupilDiameterPercentageWidth)/2, width: diameter*pupilDiameterPercentageWidth, height: diameter*pupilDiameterPercentageWidth)
    }
    
    let motionManager = MotionProvider.shared.motionManager()
    @objc func link(link: CADisplayLink) {
//        motionManager.deviceMotion?.rotationRate
        guard let motion = motionManager.deviceMotion else {return}
        
//        print("\(motion.rotationRate)")
        
        animation?.update(gravity: motion.gravity, acceleration: motion.userAcceleration)
    }
    
    override var frame: CGRect {
        didSet {
            updateDimensions()
        }
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        animation = PupilBehaviorManager(googlyEye: self, center: baseCutout.startCenter, travelRadius: diameter)
        updateDimensions()
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        animation = PupilBehaviorManager(googlyEye: self, center: baseCutout.startCenter, travelRadius: diameter)
        updateDimensions()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if orientation != currentOrientation {
            orientation = currentOrientation
            switch orientation {
            case .landscapeLeft:
                layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi/2)))
            case .landscapeRight: layer.setAffineTransform(CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2)))
            case .portraitUpsideDown: layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
            default: layer.setAffineTransform(.identity)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class HeatStamp: CALayer {
        
        var endCenter: CGPoint = .zero
        var startCenter: CGPoint = .zero
        
        let edgeShadowGradient = CGGradient(colorsSpace: nil, colors: [UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.01).cgColor, UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.6).cgColor, UIColor.clear.cgColor] as CFArray, locations: [0.78, 0.95, 0.999] as [CGFloat])
        let innerShadowGradient = CGGradient(colorsSpace: nil, colors: [GooglyEye.paperGray(alpha: 0.2).cgColor, UIColor.clear.cgColor] as CFArray, locations: nil)
        
        func update() {
            endCenter = CGPoint(x: startCenter.x, y: startCenter.y)
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
            contentsScale = UIScreen.main.scale
        }
        
        override init() {
            super.init()
            contentsScale = UIScreen.main.scale
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            let radius = GooglyEye.cutoutRadius(dimension: bounds.width)
            ctx.drawRadialGradient(edgeShadowGradient!, startCenter: endCenter, startRadius: radius - (bounds.width*0.5), endCenter: startCenter, endRadius: radius, options:  .drawsBeforeStartLocation)
            ctx.drawRadialGradient(innerShadowGradient!, startCenter: endCenter, startRadius: 1, endCenter: endCenter, endRadius: radius*0.4, options: .drawsBeforeStartLocation)
        }
    }
    
    class Pupil: UIView {
        
        let diameter: CGFloat = 11.0
        
        override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
            get {
                return .ellipse
            }
        }
        
        override class var layerClass: Swift.AnyClass {
            return PupilLayer.self
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        class PupilLayer: CAShapeLayer {
            
            override init(layer: Any) {
                super.init(layer: layer)
                contentsScale = UIScreen.main.scale
                fillColor = UIColor.black.cgColor
            }

            override init() {
                super.init()
                contentsScale = UIScreen.main.scale
                fillColor = UIColor.black.cgColor
            }
            
            override func setNeedsDisplay() {
                super.setNeedsDisplay()
                path = CGPath(ellipseIn: bounds, transform: nil)
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }
    
    class Sclera: CAShapeLayer {
        
        let stampPercentSizeDifference: CGFloat = 0.1
        let baseStampGradient = CGGradient(colorsSpace: nil, colors: [GooglyEye.grayColor().cgColor, UIColor.clear.cgColor] as CFArray, locations: nil)
        var startCenter: CGPoint = .zero
        var diameter: CGFloat = 0
        
        override init(layer: Any) {
            super.init(layer: layer)
            contentsScale = UIScreen.main.scale // this one is key
            fillColor = GooglyEye.grayColor().cgColor
        }
        
        override init() {
            super.init()
            contentsScale = UIScreen.main.scale // this one is key
            fillColor = GooglyEye.grayColor().cgColor
        }
        
        override var bounds: CGRect {
            didSet {
                diameter = GooglyEye.diameterFromFrame(rectSize: bounds.size)
                startCenter = CGPoint(x: diameter/2,
                                      y: diameter/2)
            }
        }
        
        override func setNeedsDisplay() {
            super.setNeedsDisplay()
            path = CGPath(ellipseIn: bounds, transform: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            ctx.setShouldAntialias(true)
            ctx.setAllowsAntialiasing(true)
            ctx.setFillColor(GooglyEye.grayColor().cgColor)
            let path = CGPath(ellipseIn: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: diameter, height: diameter)), transform: nil)
            ctx.addPath(path)
            ctx.fillPath()
            let radius = GooglyEye.cutoutRadius(dimension: diameter)
            ctx.drawRadialGradient(baseStampGradient!,
                                   startCenter: startCenter,
                                   startRadius: radius - (diameter*0.05),
                                   endCenter: startCenter,
                                   endRadius: radius + (diameter*0.02),
                                   options:  .drawsAfterEndLocation)
        }
    }
}
