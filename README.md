# googlyeyes

[![Version](https://img.shields.io/cocoapods/v/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![License](https://img.shields.io/cocoapods/l/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)
[![Platform](https://img.shields.io/cocoapods/p/googlyeyes.svg?style=flat)](http://cocoapods.org/pods/googlyeyes)

![alt tag](eyes-gif-vid.gif)

## Enjoy

Combine Apple's UIKitDynamics and CoreMotion frameworks for fun on iOS

## Usage

#### Initialize

##### SwiftUI

    GooglyISwiftUI(size: .init(width: 20, height: 20))

##### CGRect

    let leftEye = GooglyEye(frame: CGRect(x: 30, y: 300, width: 100, height: 100))

##### Autolayout

    let rightEye = GooglyEye.autolayout()
    
#### Configure

Make adjustments to the pupil width as a percentage of its respective sclera's diameter.

    leftEye.pupilDiameterPercentageWidth = 0.1


## Requirements

iOS 13.0

## Installation

googlyeyes is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod "googlyeyes"
```

## License

googlyeyes is available under the MIT license. See the LICENSE file for more info.
