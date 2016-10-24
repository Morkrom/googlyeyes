//
//  BevelTop.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class BevelTop: CALayer {
  
  override init() {
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(in ctx: CGContext) {
    super.draw(in: ctx)
    
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)
    
    let outerRadius = GooglyEye.cutoutRadius(dimension: bounds.width)
    let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    
    ctx.setStrokeColor(UIColor.darkGray.cgColor)
    ctx.setLineWidth(1.0)
    let frameOrigin = CGPoint(x: center.x - outerRadius, y: center.y - outerRadius)
    let frame = CGRect(origin: frameOrigin, size: CGSize(width: outerRadius*2, height: outerRadius*2))
    ctx.addPath(CGPath(ellipseIn: frame, transform: nil))
    ctx.drawPath(using: .stroke)
  }
}
