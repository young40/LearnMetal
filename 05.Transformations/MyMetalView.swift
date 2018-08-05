//
//  MyMetalView.swift
//  05.Transformations
//
//  Created by Peter Young on 2018/8/5.
//  Copyright © 2018 Peter Young. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class MyMetalView: MTKView {
    private var vertexData: [Vertex]!
    private var vertexBuffer: MTLBuffer!

    private var renderPipelineState: MTLRenderPipelineState!
    private var cmdQueue: MTLCommandQueue!

    required init(coder: NSCoder) {
        super.init(coder: coder)

        self.initDevice()
        self.initVertex()
        self.initShader()
    }

    public func initDevice() {
        self.device = MTLCreateSystemDefaultDevice()
        self.cmdQueue = self.device?.makeCommandQueue()
    }

    public func initVertex() {
        self.vertexData = [Vertex(position: [   0,  0.7, 0, 1], color: [1, 0, 0, 1]),
                           Vertex(position: [ 0.7, -0.7, 0, 1], color: [0, 1, 0, 1]),
                           Vertex(position: [-0.7, -0.7, 0, 1], color: [0, 0, 1, 1])]

        let vertexDataSize = MemoryLayout<Vertex>.size * self.vertexData.count

        self.vertexBuffer = self.device?.makeBuffer(bytes: self.vertexData, length: vertexDataSize, options: [])
    }

    public func initShader() {
        let library = self.device?.makeDefaultLibrary()

        let vertexFunc   = library?.makeFunction(name: "vertex_func")
        let fragmentFunc = library?.makeFunction(name: "fragment_func")

        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

        renderPipelineDescriptor.vertexFunction = vertexFunc
        renderPipelineDescriptor.fragmentFunction = fragmentFunc

        renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm

        renderPipelineState = try! self.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let renderPassDescriptor = self.currentRenderPassDescriptor!
        let drawable = self.currentDrawable!

        let bgColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
        renderPassDescriptor.colorAttachments[0].clearColor = bgColor

        let cmdBuffer = self.cmdQueue.makeCommandBuffer()!

        let cmdEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        cmdEncoder.setRenderPipelineState(self.renderPipelineState)
        cmdEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        cmdEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)

        cmdEncoder.endEncoding()

        cmdBuffer.present(drawable)
        cmdBuffer.commit()
    }
}
