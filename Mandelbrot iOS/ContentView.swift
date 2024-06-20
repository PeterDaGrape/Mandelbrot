//
//  ContentView.swift
//  MetalStart
//
//  Created by Peter Vine on 04/06/2024.
//

import SwiftUI
import MetalKit


struct ContentView: View {
    
    @State private var mouseLocation: CGPoint = CGPoint(x: 0, y: 0)
    @State private var zoomFactor: Float = 1.0
    
    
    @State var lastScaleValue: CGFloat = 1.0
    
    var body: some View {
        
        GeometryReader { geometry in
            MetalView(zoomFactor: $zoomFactor, mouseLocation: $mouseLocation, frameSize: geometry.size)
                .gesture(
                    MagnifyGesture()
                        .onChanged { val in
                            let delta = val.magnification / self.lastScaleValue
                            self.lastScaleValue = val.magnification
                            let newScale = CGFloat(self.zoomFactor) * delta
                            mouseLocation = val.startLocation
                            //... anything else e.g. clamping the newScale
                            self.zoomFactor = Float(newScale)
                            
                            
                        }.onEnded { val in
                            // without this the next gesture will be broken
                            self.lastScaleValue = 1.0
                        })
            
        }
        VStack {
            Text("\(zoomFactor) \(mouseLocation)")
        }
    }
}

struct MetalView: UIViewRepresentable {
    @Binding var zoomFactor: Float
    @Binding var mouseLocation: CGPoint
    var frameSize: CGSize

    func makeCoordinator() -> Renderer {
        Renderer(self)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size


      
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // Update the view if necessary
        context.coordinator.zoomFactor = zoomFactor
        context.coordinator.mouseLocation.x = mouseLocation.x * 2
        context.coordinator.mouseLocation.y = mouseLocation.y * 2

        context.coordinator.frameSize = frameSize
    }
}



#Preview {
    ContentView()
}

