//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let leftEye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
    let rightEye = GooglyEye(frame: CGRect(x: 200, y: 300, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 73/255, green: 0, blue: 1.0, alpha: 1.0)
        view.addSubview(leftEye)
        view.addSubview(rightEye)
        
        leftEye.pupilDiameterPercentageWidth = 0.6
        leftEye.mode = .immersive
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
