//
//  ViewController.swift
//  googlyeyes
//
//  Created by Michael Mork on 09/04/2016.
//  Copyright (c) 2016 Michael Mork. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      view.backgroundColor = UIColor.black
      let eye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
      view.addSubview(eye)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//plastic ring "stamping" 
//  gray plastic "sheen", dark gray thin gradiated edge 
//  - 5-10% of width is stamp, random distance to edge of eye ball - include new actual center offset and boundary dimension for pupil
// static electricity area rub - (save points in a decaying rubbing buffer from a pan gesture)
// 6 add sheen gradient view corresponding to gravity direction
// 3 support for autolayout

/*
 - STATIC -
   pan gesture recognizer:
   - the CGPoint
   - have a points list with [point, media time]
*/
