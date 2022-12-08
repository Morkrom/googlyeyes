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
    
    let pupil = Pupil()
    
    class func grayColor() -> UIColor {  GooglyEye.paperGray(alpha: 1.0) }
    class func paperGray(alpha: CGFloat) -> UIColor {
        UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: alpha)}
    
    class func cutoutRadius(dimension: CGFloat) -> CGFloat { dimension/2 * 0.97}
    
    class func diameterFromFrame(rectSize: CGSize) -> CGFloat { rectSize.width > rectSize.height ? rectSize.height : rectSize.width}
    
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
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.preferredFramesPerSecond = 32
        layer.addSublayer(baseCutout)
        addSubview(pupil)
        layer.addSublayer(innerStamp)
//        layer.insertSublayer(pupil.layer, below: innerStamp)
        
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

        adjustPupilForNewWidth()
        pupil.layer.setNeedsDisplay()

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

//    override func setNeedsLayout() {
//        super.setNeedsLayout()
//        animation = PupilBehaviorManager(googlyEye: self, center: baseCutout.startCenter, travelRadius: diameter)
//        updateDimensions()
//    }

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
}
