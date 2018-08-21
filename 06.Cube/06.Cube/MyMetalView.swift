//
//  MyMetalView.swift
//  06.Cube
//
//  Created by 杨世玲 on 2018/8/19.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import MetalKit

class MyMetalView: MTKView {
    var queue: MTLCommandQueue!
    var vertexBuffer: MTLBuffer!
    var uniformBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var renderPipelineState: MTLRenderPipelineState!
    
    var vertexData: [Vertex]!
    var indexData: [UInt16]!
    
    var rotation: Float = 0
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()
        queue = device?.makeCommandQueue()
        
        self.initVertex()
        self.initShaders()
    }
    
    private func initVertex() {
        vertexData = [
            Vertex(pos: [-1.0, -1.0,  1.0, 1.0], col: [1, 1, 1, 1]),
            Vertex(pos: [ 1.0, -1.0,  1.0, 1.0], col: [1, 0, 0, 1]),
            Vertex(pos: [ 1.0,  1.0,  1.0, 1.0], col: [1, 1, 0, 1]),
            Vertex(pos: [-1.0,  1.0,  1.0, 1.0], col: [0, 1, 0, 1]),
            
            Vertex(pos: [-1.0, -1.0, -1.0, 1.0], col: [0, 0, 1, 1]),
            Vertex(pos: [ 1.0, -1.0, -1.0, 1.0], col: [1, 0, 1, 1]),
            Vertex(pos: [ 1.0,  1.0, -1.0, 1.0], col: [0, 0, 0, 1]),
            Vertex(pos: [-1.0,  1.0, -1.0, 1.0], col: [0, 1, 1, 1])]
        
        indexData = [0, 1, 2, 2, 3, 0,   // front
            1, 5, 6, 6, 2, 1,   // right
            3, 2, 6, 6, 7, 3,   // top
            4, 5, 1, 1, 0, 4,   // bottom
            4, 0, 3, 3, 7, 4,   // left
            7, 6, 5, 5, 4, 7]   // back
        
        vertexBuffer  = self.device?.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size*vertexData.count, options: [])
        indexBuffer   = self.device?.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size*indexData.count, options: [])
        uniformBuffer = self.device?.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
    }
    
    private func initShaders() {
        do {
            let library = device?.makeDefaultLibrary()
            let vert_func = library?.makeFunction(name: "vertex_func")
            let frag_func = library?.makeFunction(name: "fragment_func")
            let renderPipelineDesriptor = MTLRenderPipelineDescriptor()
            renderPipelineDesriptor.vertexFunction = vert_func
            renderPipelineDesriptor.fragmentFunction = frag_func
            renderPipelineDesriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
            self.renderPipelineState = try device?.makeRenderPipelineState(descriptor: renderPipelineDesriptor)
        } catch let e {
            fatalError("\(e)")
        }
    }
    
    func update() {
        let scaledMatrix = scalingMatrix(scale: 0.5)
        
        rotation += 1/100 * Float.pi / 4
        let rotatedY = rotationMatrix(angle: rotation, axis: float3(0, 1, 0))
        let rotatedX = rotationMatrix(angle: Float.pi/4, axis: float3(1, 0, 0))
        
        let modleMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaledMatrix)
        
        let camerPosition = vector_float3(0, 0, -3)
        
        let viewMatrix = translationMatrix(position: camerPosition)
        
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: 1, fovy: 1)
        
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modleMatrix))
        
        let bufferPointer = uniformBuffer.contents()
        
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        update()
        
        let currentRenderPassDescriptor = self.currentRenderPassDescriptor!
        let drawable = self.currentDrawable!
        
        let commandBuffer  = queue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        
        currentRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
        
        commandEncoder?.setRenderPipelineState(renderPipelineState)
        commandEncoder?.setFrontFacing(MTLWinding.counterClockwise)
        commandEncoder?.setCullMode(MTLCullMode.back)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        commandEncoder?.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: indexBuffer.length/MemoryLayout<UInt16>.size, indexType: MTLIndexType.uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
