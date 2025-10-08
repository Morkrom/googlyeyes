// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

@available(iOS 13.0, *)
struct GooglyISwiftUI: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GooglyEye {
        return GooglyEye(frame: .init(x: 0, y: 0, width: 40, height: 40))
    }
    
    func updateUIView(_ uiView: GooglyEye, context: Context) {
        
    }
}

class EyeContainerView: UIView {
    
    private let eye = GooglyEye()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(eye)
        eye.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        eye.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eye.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        eye.heightAnchor.constraint(equalToConstant: frame.height).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
