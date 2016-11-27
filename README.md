# googlyeyes

[![CI Status](http://img.shields.io/travis/Michael Mork/googlyeyes.svg?style=flat)](https://travis-ci.org/Michael Mork/googlyeyes)
[![Version](https://img.shields.io/cocoapods/v/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![License](https://img.shields.io/cocoapods/l/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![Platform](https://img.shields.io/cocoapods/p/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)

![alt tag](eyes-gif-vid.gif)

## Life is short

Spread cheer and stereoscopic anthropomorphism in all screen orientations. Demonstrate the power of Apple's abstractions provided by UIKit, CALayer, and CoreMotion to your mobile team.

## Usage

Pretty standard, really.

    let leftEye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
    myAppsview.addSubview(leftEye)

If you want a 3-D effect, consider the mode property, which defaults to .performant. Setting it to .immersive enables pitch and roll on the 'sheen' which 'encloses' the pupil view.

	leftEye.mode = .immersive

Make adjustments to the pupil width as a percentage of its respective sclera's diameter.
    
    leftEye.pupilDiameterPercentageWidth = 0.6

If your app has an existing instance of CMMotionManager, be certain to set your app's instance of it on the MotionProvider class before allocationg any GooglyEyes like so:

    MotionProvider.shared.coreMotionManager = myAppsMotionManager
    //.. create GooglyEyes

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 9.0

## Installation

googlyeyes is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "googlyeyes"
```

## Author
Michael Mork, morkrom@protonmail.ch
Email me!

## License

googlyeyes is available under the MIT license. See the LICENSE file for more info.
