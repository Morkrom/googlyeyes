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
    private var animation: GooglyEyesDynamicAnimation?

    private var diameter: CGFloat = 0
    private var orientation = UIApplication.shared.statusBarOrientation
    private var baseCutout = Sclera()
    private let innerStamp = HeatStamp()
    
    var percentilePupilMoved: CGPoint = .zero {
        didSet {
            
            displayLink?.remove(from: .main, forMode: .default)
            displayLink = nil
//            displayLink?.remove(from: .main, forMode: .default)
//            displayLink = nil
//            animation?.stop()
//            animation = nil
            
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
            
            /*
            
            let pupilD = diameter*pupilDiameterPercentageWidth*0.97
            let pupilCenterXOffsetted = (diameter - pupilD)/2

            print("::: saniX: \(saniX), saniY: \(saniY)")
            let newPupilOrigin: CGPoint = .init(x: pupilD/2*saniX,//+ pupilCenterXOffsetted,
                                                y: pupilD/2*saniY)// + pupilD/2)
            
            UIView.animate(withDuration: 0.15) { [weak self] in
                guard let self else {
                    return
                }
                pupil.frame = .init(origin: newPupilOrigin,
                                    size: .init(width: pupilD, height: pupilD))
            }*/
            
            animation?.update(percentilePosition: CGPoint(x: saniX, y: saniY))
//            animation?.moveToVector(percentilePupilMoved)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        doCommonConfig()
        updateDimensions()
    }
    
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        displayLink = CADisplayLink(target: self, selector: #selector(GooglyEye.link))
        doCommonConfig()
        updateDimensions()
    }

    private func doCommonConfig() {
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.preferredFramesPerSecond = 32
        layer.addSublayer(baseCutout)
        addSubview(pupil)
        layer.addSublayer(innerStamp)
        
        self.animation = GooglyEyesDynamicAnimation(motionManager: motionManager,
                                                    googlyEye: self,
                                                    center: baseCutout.startCenter)
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
        animation?.updateBehaviors(center: baseCutout.startCenter,
                                   travelRadius: GooglyEye.cutoutRadius(dimension: diameter))
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
            animation = GooglyEyesDynamicAnimation(motionManager: motionManager,
                                                   googlyEye: self,
                                                   center: baseCutout.startCenter)
            updateDimensions()
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


