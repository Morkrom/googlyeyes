//
//  BevelBase.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

@objc class BevelBase: CALayer {
  let grayColor = UIColor(colorLiteralRed: 0.83, green: 0.83, blue: 0.8, alpha: 1.0).cgColor
  let stampPercentSizeDifference: CGFloat = 0.1
  var startCenter: CGPoint = .zero
  var endCenter: CGPoint = .zero
    
    override init() {
        super.init()
    }
  
  func update(pitchPercent: CGFloat, rollPercent: CGFloat) {
    endCenter = CGPoint(x: startCenter.x + (rollPercent*10.0), y: startCenter.y + (pitchPercent*10.0))
    setNeedsDisplay()
  }
  
  override var bounds: CGRect {
    didSet {
      startCenter = CGPoint(x: bounds.width/2 + ((bounds.width/2*0.1) * randomPercent()),
                            y: bounds.height/2 + ((bounds.height/2*0.1) * randomPercent()))
      endCenter = startCenter
    }
  }
  
  func randomPercent() -> CGFloat {
    return CGFloat(Int(arc4random_uniform(100)) - 50) / 100.0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(in ctx: CGContext) {
    
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    
    ctx.clear(bounds)
    
    ctx.setFillColor(GooglyEye.plasticGrayColor().cgColor)
    
    let radius = GooglyEye.cutoutRadius(dimension: bounds.width)
    guard let baseStampGradient = CGGradient(colorsSpace: nil, colors: [UIColor.clear.cgColor, grayColor, UIColor.clear.cgColor] as CFArray, locations: [0, 0.01, 0.9]) as CGGradient? else {return}
    ctx.addPath(CGPath(ellipseIn: CGRect(x: startCenter.x - radius, y: startCenter.y - radius, width: radius*2, height: radius*2), transform: nil))

//    ctx.clip()
//    ctx.setFillColor(UIColor.clear.cgColor)
//    ctx.fill(bounds)

    ctx.drawRadialGradient(baseStampGradient,
                           startCenter: startCenter,
                           startRadius: radius,
                           endCenter: startCenter,
                           endRadius: radius - 2,
                           options: .drawsAfterEndLocation)
    
//    ctx.setStrokeColor(grayColor)
//    ctx.setLineWidth(2)
//    let frameOrigin = CGPoint(x: startCenter.x - radius, y: startCenter.y - radius)
//    let frame = CGRect(origin: frameOrigin, size: CGSize(width: radius*2, height: radius*2))
//    ctx.addPath(CGPath(ellipseIn: frame, transform: nil))
//    ctx.strokePath()
    
    return /*
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    
    ctx.clip()
    ctx.fill(bounds)
    ctx.clear(bounds)
    let baseStampGradient = CGGradient(colorsSpace: nil,
                                       colors: [UIColor.clear.cgColor, grayColor] as CFArray,
                                       locations: nil)
    
    let radius = GooglyEye.cutoutRadius(dimension: bounds.width)
    ctx.drawRadialGradient(baseStampGradient!,
                           startCenter: startCenter,
                           startRadius: radius,
                           endCenter: startCenter,
                           endRadius: radius,
                           options: .drawsBeforeStartLocation)
    
    ctx.setStrokeColor(grayColor)
    ctx.setLineWidth(2)
    let frameOrigin = CGPoint(x: startCenter.x - radius, y: startCenter.y - radius)
    let frame = CGRect(origin: frameOrigin, size: CGSize(width: radius*2, height: radius*2))
    ctx.addPath(CGPath(ellipseIn: frame, transform: nil))
    ctx.drawPath(using: .stroke)*/
  }
}

