//
//  FloatingRingView.swift
//  googlyeyes
//
//  Created by Michael Mork on 10/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class FloatingRingView: UIView {

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addEffect(horizontalTotalRelativeRange: CGFloat, verticalTotalRelativeRange: CGFloat) {
    
    let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    horizontalMotionEffect.minimumRelativeValue = -horizontalTotalRelativeRange/2
    horizontalMotionEffect.maximumRelativeValue = horizontalTotalRelativeRange/2
    addMotionEffect(horizontalMotionEffect)
    
    let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    verticalMotionEffect.minimumRelativeValue = -verticalTotalRelativeRange/2
    verticalMotionEffect.maximumRelativeValue = verticalTotalRelativeRange/2
    addMotionEffect(verticalMotionEffect)
  }
  
  override open class var layerClass: Swift.AnyClass {
    return BevelTop.self
  }
  
  override var frame: CGRect {
    didSet {
      if frame != .zero {
        layer.setNeedsDisplay()
      }
    }
  }
}
