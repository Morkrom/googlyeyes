//
//  GooglyEye.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

enum Mode {
    case performant
    case immersive
}

class GooglyEye: UIView {
    
    var pupilDiameterPercentageWidth: CGFloat = 0.5 {
        didSet {
            adjustPupilForNewWidth()
        }
    }
    
    var mode: Mode = .performant
    var pupilView = Pupil()
    
    private class func plasticGrayColor() -> UIColor { return GooglyEye.plasticGrayColor(alpha: 1.0) }//That shitty yellowing gray color for degrading clear plastic.
    private class func plasticGrayColor(alpha: CGFloat) -> UIColor { return UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: alpha) }
    private class func cutoutRadius(dimension: CGFloat) -> CGFloat {return dimension/2 * 0.85}
    private class func diameterFromFrame(rectSize: CGSize) -> CGFloat { return rectSize.width > rectSize.height ? rectSize.height : rectSize.width }
    
    private var displayLink: CADisplayLink!
    private var animation: PupilAnimation?
    private var diameter: CGFloat = 0
    private var orientation = UIApplication.shared.statusBarOrientation
    private var baseCutout = BaseCutout()
    private let innerStamp = HeatStamp()
  
    override init(frame: CGRect) {
        super.init(frame: frame)

        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        displayLink.frameInterval = 2

        pupilView.backgroundColor = UIColor.clear

        diameter = GooglyEye.diameterFromFrame(rectSize: frame.size)

        innerStamp.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        innerStamp.bounds = CGRect(x: -diameter/2, y: -diameter/2, width: diameter, height: diameter)
        innerStamp.update(pitchPercent: 0, rollPercent: 0)// Centered

        layer.addSublayer(baseCutout)
        addSubview(pupilView)
        layer.insertSublayer(innerStamp, above: pupilView.layer)
        baseCutout.frame = innerStamp.frame
        baseCutout.setNeedsDisplay()
        
        pupilView.frame = CGRect(x: (bounds.width - diameter*pupilDiameterPercentageWidth)/2, y: (bounds.height - diameter*pupilDiameterPercentageWidth)/2, width: diameter*pupilDiameterPercentageWidth, height: diameter*pupilDiameterPercentageWidth)
        
        pupilView.layer.setNeedsDisplay()
        
        animation = PupilAnimation(googlyEye: self, center: baseCutout.startCenter, travelRadius: GooglyEye.cutoutRadius(dimension: bounds.width))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let currentOrientation = UIApplication.shared.statusBarOrientation
        if orientation != currentOrientation {
            orientation = currentOrientation
            switch orientation {
            case .landscapeLeft:
                layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI_2)))
            case .landscapeRight:
                layer.setAffineTransform(CGAffineTransform(rotationAngle: -CGFloat(M_PI_2)))
            case .portraitUpsideDown: layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI)))
            default:
                layer.setAffineTransform(.identity)
            }
        }
    }
    
    private func adjustPupilForNewWidth() {
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
    
    func link(link: CADisplayLink) {
        
        guard let motion = MotionProvider.shared.motionManager().deviceMotion else {return}
        let pitchPercent = CGFloat(motion.attitude.pitch)/CGFloat(1.5)
        let rollPercent = CGFloat(motion.attitude.roll)/CGFloat(1.5)
        animation?.update(gravity: motion.gravity, acceleration: motion.userAcceleration)
        if mode == .immersive {
            innerStamp.update(pitchPercent:pitchPercent, rollPercent: rollPercent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class Pupil: UIView {
        
        override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
            get {
                return .ellipse
            }
        }
        
        override class var layerClass: Swift.AnyClass {
            return PupilLayer.self
        }
        
        class PupilLayer: CALayer {
            override init() {
                super.init()
                contentsScale = UIScreen.main.scale
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override func draw(in ctx: CGContext) {
                super.draw(in: ctx)
                ctx.setFillColor(UIColor.black.cgColor)
                let diameter = GooglyEye.diameterFromFrame(rectSize: frame.size)
                ctx.addEllipse(in: CGRect(origin: CGPoint(x: (bounds.width - diameter), y: (bounds.height - diameter)), size: CGSize(width: diameter, height: diameter)))
                ctx.fillPath()
            }
        }
    }

    class BaseCutout: CALayer {
        let stampPercentSizeDifference: CGFloat = 0.1
        let baseStampGradient = CGGradient(colorsSpace: nil, colors: [GooglyEye.plasticGrayColor().cgColor, UIColor.clear.cgColor] as CFArray, locations: nil)
        var startCenter: CGPoint = .zero
        var diameter: CGFloat = 0
        
        override init(layer: Any) {
            super.init(layer: layer)
            contentsScale = UIScreen.main.scale // this one is key
        }
        
        override init() {
            super.init()
            contentsScale = UIScreen.main.scale // this one is key
        }
        
        override var bounds: CGRect {
            didSet {
                diameter = GooglyEye.diameterFromFrame(rectSize: bounds.size)
                startCenter = CGPoint(x: diameter/2 + ((diameter/2*0.1) * randomPercent()),
                                      y: diameter/2 + ((diameter/2*0.1) * randomPercent()))
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
//            ctx.setBlendMode(.clear)
//            ctx.clear(bounds)
            ctx.setBlendMode(.normal)
            ctx.setFillColor(GooglyEye.plasticGrayColor().cgColor)
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
    
    class HeatStamp: CALayer {
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
        
        override init(layer: Any) {
            super.init(layer: layer)
            contentsScale = UIScreen.main.scale
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
            ctx.drawRadialGradient(edgeShadowGradient!, startCenter: endCenter, startRadius: radius - (bounds.width*0.1),
                                   endCenter: startCenter, endRadius: radius + (bounds.width*0.035), options:  .drawsBeforeStartLocation)
            ctx.drawRadialGradient(innerShadowGradient!, startCenter: endCenter, startRadius: 1, endCenter: endCenter, endRadius: radius*0.4, options: .drawsBeforeStartLocation)
        }
    }
}
