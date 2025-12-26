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

public class GooglyEye: UIView {
    
    private let motionManager = CMMotionManager()
    
    let pupil = Pupil()
    
    class func grayColor() -> UIColor {  GooglyEye.paperGray(alpha: 1.0) }
    class func paperGray(alpha: CGFloat) -> UIColor {
        UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: alpha)}
    
    class func cutoutRadius(dimension: CGFloat) -> CGFloat { dimension/2 * 0.97}
    
    class func diameterFromFrame(rectSize: CGSize) -> CGFloat { rectSize.width > rectSize.height ? rectSize.height : rectSize.width}
    
    private var displayLink: CADisplayLink!
    private var animation: GooglyEyesDynamicAnimation?

    private var diameter: CGFloat = 0
    private var orientation = UIApplication.shared.statusBarOrientation
    private var baseCutout = Sclera()
    private let innerStamp = HeatStamp()
    
    
    var pupilDiameterPercentageWidth: CGFloat = 0.62 {
        didSet {
            updateDimensions()
            animation?.updateBehaviors(center: baseCutout.startCenter,
                                       travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
        }
    }
    
    var percentilePupilMoved: CGPoint = .zero {
        didSet {
            
            displayLink?.remove(from: .main, forMode: .default)
            displayLink = nil

            var saniX = percentilePupilMoved.x
            
            if percentilePupilMoved.x > 1 {
                saniX = 1
            } else if percentilePupilMoved.x < -1 {
                saniX = -1
            }

            var saniY = percentilePupilMoved.y
            if percentilePupilMoved.y > 1 {
                saniY = 1
            } else if percentilePupilMoved.y < -1 {
                saniY = -1
            }
            
            animation?.update(percentilePosition: CGPoint(x: saniX, y: saniY))
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        doCommonConfig()
        updateDimensions()
        animation?.updateBehaviors(center: baseCutout.startCenter,
                                   travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
    }
    
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        doCommonConfig()
        updateDimensions()
        animation?.updateBehaviors(center: baseCutout.startCenter,
                                   travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
    }

    private func doCommonConfig() {
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.preferredFramesPerSecond = 32
        layer.addSublayer(baseCutout)
        addSubview(pupil)
        layer.addSublayer(innerStamp)
        
        self.animation = GooglyEyesDynamicAnimation(motionManager: motionManager,
                                                    googlyEye: self)
    }
    
    private func updateDimensions() {
        guard animation != nil else {
            return
        }
        
        diameter = GooglyEye.diameterFromFrame(rectSize: bounds.size)
        
        baseCutout.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        innerStamp.startCenter = baseCutout.startCenter
        innerStamp.frame = baseCutout.bounds

        adjustPupilForNewWidth()
        pupil.layer.setNeedsDisplay()

        innerStamp.update()

        baseCutout.setNeedsDisplay()
        innerStamp.setNeedsDisplay()
    }
    
    private func adjustPupilForNewWidth() {
        if pupilDiameterPercentageWidth > 1.0 {
            pupilDiameterPercentageWidth = 1.0
        } else if pupilDiameterPercentageWidth < 0 {
            pupilDiameterPercentageWidth = 0.01
        }
        
        pupil.frame = CGRect(x: pupil.frame.minX - (pupil.frame.width - diameter*pupilDiameterPercentageWidth)/2,
                             y: pupil.frame.minY - (pupil.frame.height - diameter*pupilDiameterPercentageWidth)/2,
                             width: diameter*pupilDiameterPercentageWidth,
                             height: diameter*pupilDiameterPercentageWidth)
    }
    
    @objc func link(link: CADisplayLink) {
        guard let motion = motionManager.deviceMotion else {return}
        animation?.update(gravity: motion.gravity, acceleration: motion.userAcceleration)
    }

    public override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        if percentilePupilMoved != .zero {
            updateDimensions()
            animation?.updateBehaviors(center: baseCutout.startCenter,
                                       travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
        }
    }
    
    public override func layoutSubviews() {
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
}


