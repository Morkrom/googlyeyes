//
//  HeatStamp.swift
//  Sillytime
//
//  Created by apple on 12/6/22.
//

import Foundation
import QuartzCore
import UIKit

class HeatStamp: CALayer {
    
    var endCenter: CGPoint = .zero
    var startCenter: CGPoint = .zero
    
    let edgeShadowGradient = CGGradient(colorsSpace: nil,
                                        colors: [UIColor(red: 0.2, green: 0.1, blue: 0.2, alpha: 0.01).cgColor, 
                                                 UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 0.6).cgColor,
                                                 UIColor.clear.cgColor] as CFArray,
                                        locations: [0.78, 0.95, 0.999] as [CGFloat])
    
    let innerShadowGradient = CGGradient(colorsSpace: nil,
                                         colors: [GooglyEye.paperGray(alpha: 0.2).cgColor,
                                                  UIColor.clear.cgColor] as CFArray,
                                         locations: nil)
    
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
        ctx.drawRadialGradient(edgeShadowGradient!, 
                               startCenter: endCenter,
                               startRadius: radius - (bounds.width*0.5),
                               endCenter: startCenter,
                               endRadius: radius,
                               options:  .drawsBeforeStartLocation)
        ctx.drawRadialGradient(innerShadowGradient!,
                               startCenter: endCenter,
                               startRadius: 1,
                               endCenter: endCenter,
                               endRadius: radius*0.4,
                               options: .drawsBeforeStartLocation)
    }
}
