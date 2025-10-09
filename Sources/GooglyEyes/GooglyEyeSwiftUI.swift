// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

public struct GooglyEyeSwiftUI: UIViewRepresentable {
    
    let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }
    
    public func makeUIView(context: Context) -> GooglyEye {
        return GooglyEye(frame: .init(x: 0, y: 0, width: size.width, height: size.height))
    }
    
    public func updateUIView(_ uiView: GooglyEye, context: Context) {
        
    }
}
