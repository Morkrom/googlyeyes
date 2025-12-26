// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct GooglyEyeSwiftUI: UIViewRepresentable {
    
    private let size: CGFloat
    private let originalSize: CGFloat?
    @Binding private var percentilePupilMoved: CGPoint?
    private var pupilDiameterPercentageWidth: CGFloat?

    public init(size: CGFloat,
                percentilePupilMoved: Binding<CGPoint?>,
                pupilDiameterPercentageWidth: CGFloat?) {
        self.pupilDiameterPercentageWidth = pupilDiameterPercentageWidth
        self.size = size
        self._percentilePupilMoved = percentilePupilMoved
        originalSize = nil
    }
    
    public init(size: CGFloat,
                originalSize: CGFloat,
                percentilePupilMoved: Binding<CGPoint?>,
                pupilDiameterPercentageWidth: CGFloat?) {
        self.pupilDiameterPercentageWidth = pupilDiameterPercentageWidth
        self.size = size
        self._percentilePupilMoved = percentilePupilMoved
        self.originalSize = originalSize
    }
    
    public func makeUIView(context: Context) -> GooglyEye {
        let goog = GooglyEye(frame: .init(x: 0, y: 0, width: size, height: size))
        if let customPup = pupilDiameterPercentageWidth {
            goog.pupilDiameterPercentageWidth = customPup
        }
        return goog
    }
    
    public func updateUIView(_ uiView: GooglyEye, context: Context) {
        if let percentilePupilMoved {
            uiView.percentilePupilMoved = percentilePupilMoved
        }
        
        if let originalSize {
            if #available(iOS 16.0, *) {
                uiView.anchorPoint = .init(x: 0.5, y: 0.5)
            } else {
                // Fallback on earlier versions
            }
            let scale = size/originalSize
            uiView.transform = .init(scaleX: scale, y: scale)
        }
    }
}
