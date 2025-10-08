//
//  Sclera.swift
//  Sillytime
//
//  Created by apple on 12/6/22.
//

import Foundation
import QuartzCore
import UIKit

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
