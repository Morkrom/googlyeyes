# googlyeyes

[![CI Status](http://img.shields.io/travis/Michael Mork/googlyeyes.svg?style=flat)](https://travis-ci.org/Michael Mork/googlyeyes)
[![Version](https://img.shields.io/cocoapods/v/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![License](https://img.shields.io/cocoapods/l/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![Platform](https://img.shields.io/cocoapods/p/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)

![alt tag](eyes-gif-vid.gif)

## Usage

Pretty standard, really.

    let leftEye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))
    myAppsview.addSubview(leftEye)

If you want to push your graphics, set the eye's mode property to .immersive. This enables pitch and roll on the 'sheen' which 'encloses' the pupil view.

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

## License

googlyeyes is available under the MIT license. See the LICENSE file for more info.
