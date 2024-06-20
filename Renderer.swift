//
//  Renderer.swift
//  MetalStart
//
//  Created by Peter Vine on 04/06/2024.
//

import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    var zoomFactor: Float = 1.0
    var mouseLocation: CGPoint = CGPoint(x: 0, y: 0)
    var prevMouseLocation: CGPoint = CGPoint(x: 0, y: 0)
    var prevZoomFactor: Float = 1.0
    var parent: MetalView
    
    var frameSize: CGSize = CGSize(width: 0, height: 0)
    
    let initialStartX: Double = -2.0
    let initialStartY: Double = -1.2
    let initialStopY: Double = 1.2
    let initialStopX: Double = 0.6

    
    var startX: Double
    var startY: Double
    var stopY: Double
    var stopX: Double

    var complexStep: Double = 0
    
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    
    
    
    var vertices = [
        Vertex(position: [-1, -1], complexPosition: [-2, -1.2]),
        Vertex(position: [1, -1], complexPosition: [2, -1.2]),
        Vertex(position: [-1, 1], complexPosition: [-2, 1.2]),
        Vertex(position: [1, 1], complexPosition: [2, 1.2])


    ]
    
    
    init(_ parent: MetalView) {
        
        
        startX = initialStartX
        startY = initialStartY
        stopY = initialStopY
        stopX = initialStopX
        self.parent = parent
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
        }
    
        
        
        
        self.metalCommandQueue = metalDevice.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        let library = metalDevice.makeDefaultLibrary()
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            try pipelineState = metalDevice.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            
            fatalError()
        }
            
        
        
        
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        
        super.init()
        
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    
    func draw(in view: MTKView) {
        
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let renderTargetTexture = drawable.texture
        let width = renderTargetTexture.width
        let height = renderTargetTexture.height
        
        let commandBuffer = metalCommandQueue.makeCommandBuffer()
        
        let renderPassDescriptor = view.currentRenderPassDescriptor
        
        renderPassDescriptor?.colorAttachments[0].clearColor = MTLClearColor(red:0, green:0.5, blue:0.5, alpha:1.0)
        renderPassDescriptor?.colorAttachments[0].loadAction = .clear
        renderPassDescriptor?.colorAttachments[0].storeAction = .store
        
        
        let complexStepX = (stopX - startX) / Double(width)
        let complexStepY = (stopY - startY) / Double(height)

        
        let mouseX: Double = Double(mouseLocation.x)
        let mouseY: Double = Double(CGFloat(height) - mouseLocation.y)
        
        let complexMouseX = startX + mouseX * complexStepX
        let complexMouseY = startY + mouseY * complexStepY

        
        
        let scale: Double = 1.0 / Double(zoomFactor - prevZoomFactor + 1)
        
        
        let newWidth = (stopX - startX) * scale
        let newHeight = (stopY - startY) * scale

        startX = complexMouseX - newWidth * (mouseX / Double(width))
        stopX = startX + newWidth

        startY = complexMouseY - newHeight * (mouseY / Double(height))
        stopY = startY + newHeight

        prevZoomFactor = zoomFactor
        
        
        
        
        vertices = [
            Vertex(position: [-1, -1], complexPosition: [Float(startX), Float(startY)]),
            Vertex(position: [1, -1], complexPosition: [Float(stopX), Float(startY)]),
            Vertex(position: [-1, 1], complexPosition: [Float(startX), Float(stopY)]),
            Vertex(position: [1, 1], complexPosition: [Float(stopX), Float(stopY)])
        ]
        
        
        
        let vertexBuffer = metalDevice.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!

        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}
