//
//  PupilLayer.swift
//  Sillytime
//
//  Created by apple on 12/6/22.
//

import Foundation
import QuartzCore
import UIKit

class PupilLayer: CAShapeLayer {
    
    override init(layer: Any) {
        super.init(layer: layer)
        contentsScale = UIScreen.main.scale
        fillColor = UIColor.black.cgColor
    }

    override init() {
        super.init()
        contentsScale = UIScreen.main.scale
        fillColor = UIColor.black.cgColor
    }
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        path = CGPath(ellipseIn: bounds, transform: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
