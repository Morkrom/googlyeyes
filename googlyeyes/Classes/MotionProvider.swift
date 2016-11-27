//
//  MotionProvider.swift
//  googlyeyes
//
//  Created by Michael Mork on 11/24/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import CoreMotion

class MotionProvider {
    
    static let shared = MotionProvider()
    var coreMotionManager: CMMotionManager? // set this before initializing an eye if your app has its own instance of CMMotionManager
    
    func motionManager() -> CMMotionManager {
        if let mm = coreMotionManager {
            return mm
        } else {
            coreMotionManager = CMMotionManager()
            return coreMotionManager!
        }
    }
}
