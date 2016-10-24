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
  
  override open class var layerClass: Swift.AnyClass {
    return BevelTop.self
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var frame: CGRect {
    didSet {
      if frame != .zero {
        layer.setNeedsDisplay()
      }
    }
  }
}
