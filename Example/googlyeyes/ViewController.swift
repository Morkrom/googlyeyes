//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let bigOne = GooglyEye.autoLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 73/255, green: 0, blue: 1.0, alpha: 1.0)

        bigOne.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(bigOne)
      
        let layoutGuide = UILayoutGuide()
        view.addLayoutGuide(layoutGuide)
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                bigOne.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                bigOne.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                bigOne.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                bigOne.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
            ])
        } else {
            // Fallback on earlier versions
        }
  
        bigOne.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
