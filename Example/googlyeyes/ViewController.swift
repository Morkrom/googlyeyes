//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let leftEye = GooglyEye(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let rightEye = GooglyEye(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 73/255, green: 0, blue: 1.0, alpha: 1.0)
        view.addSubview(leftEye)
        view.addSubview(rightEye)
      
        leftEye.translatesAutoresizingMaskIntoConstraints = false
        rightEye.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                layoutGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                layoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),//.constraint(equalTo: view.centerYAnchor),
                layoutGuide.widthAnchor.constraint(equalToConstant: 50),
                leftEye.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
                rightEye.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
                leftEye.rightAnchor.constraint(equalTo: layoutGuide.leftAnchor),
                rightEye.leftAnchor.constraint(equalTo: layoutGuide.rightAnchor),
                leftEye.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
                rightEye.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3)
            ])
        } else {
            // Fallback on earlier versions
        }
        
        leftEye.pupilDiameterPercentageWidth = 0.6
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
