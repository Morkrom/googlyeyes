// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct GooglyEyeSwiftUI: UIViewRepresentable {
    
    private let size: CGSize
    
    @Binding private var percentilePupilMoved: CGPoint?
    private var pupilDiameterPercentageWidth: CGFloat?

    public init(size: CGSize,
                percentilePupilMoved: Binding<CGPoint?>,
                pupilDiameterPercentageWidth: CGFloat?) {
        self.pupilDiameterPercentageWidth = pupilDiameterPercentageWidth
        self.size = size
        self._percentilePupilMoved = percentilePupilMoved
    }
    
    public func makeUIView(context: Context) -> GooglyEye {
        let goog = GooglyEye(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
        if let customPup = pupilDiameterPercentageWidth {
            goog.pupilDiameterPercentageWidth = customPup
        }
        return goog
    }
    
    public func updateUIView(_ uiView: GooglyEye, context: Context) {
        if let pp = percentilePupilMoved {
            uiView.percentilePupilMoved = pp
        }
    }
}
