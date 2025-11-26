// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct GooglyEyeSwiftUI: UIViewRepresentable {
    
    private let size: CGSize
    
    @Binding private var percentilePupilMoved: CGPoint?

    public init(size: CGSize,
                percentilePupilMoved: Binding<CGPoint?>) {
        self.size = size
        self._percentilePupilMoved = percentilePupilMoved
    }
    
    public func makeUIView(context: Context) -> GooglyEye {
        return GooglyEye(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    public func updateUIView(_ uiView: GooglyEye, context: Context) {
        if let pp = percentilePupilMoved {
            uiView.percentilePupilMoved = pp
        }
    }
}
