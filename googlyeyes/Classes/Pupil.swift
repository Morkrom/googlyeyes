//
//  Pupil.swift
//  Sillytime
//
//  Created by apple on 12/6/22.
//

import Foundation
import UIKit

class Pupil: UIView {
    
    let diameter: CGFloat = 11.0
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        get {
            return .ellipse
        }
    }
    
    override class var layerClass: Swift.AnyClass {
        return PupilLayer.self
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
            layer.frame = bounds
        }
    }
}
