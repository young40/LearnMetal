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
    
    var rotation: Float = 0
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()
        queue = device?.makeCommandQueue()
        
        self.initVertex()
        self.initShaders()
    }
    
    private func initVertex() {
        let vertexData = [
            Vertex(pos: [-1.0, -1.0,  1.0, 1.0], col: [1, 1, 1, 1]),
            Vertex(pos: [ 1.0, -1.0,  1.0, 1.0], col: [1, 0, 0, 1]),
            Vertex(pos: [ 1.0,  1.0,  1.0, 1.0], col: [1, 1, 0, 1]),
            Vertex(pos: [-1.0,  1.0,  1.0, 1.0], col: [0, 1, 0, 1]),
            
            Vertex(pos: [-1.0, -1.0, -1.0, 1.0], col: [0, 0, 1, 1]),
            Vertex(pos: [ 1.0, -1.0, -1.0, 1.0], col: [1, 0, 1, 1]),
            Vertex(pos: [ 1.0,  1.0, -1.0, 1.0], col: [0, 0, 0, 1]),
            Vertex(pos: [-1.0,  1.0, -1.0, 1.0], col: [0, 1, 1, 1])]
        
        let indexData: [UInt16] = [0, 1, 2, 2, 3, 0,   // front
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
            let library = try device?.makeDefaultLibrary()
            let vert_func = library?.makeFunction(name: "vertex_func")
            let frag_func = library?.makeFunction(name: "frag_func")
            let renderPipelineDesriptor = MTLRenderPipelineDescriptor()
            renderPipelineDesriptor.vertexFunction = vert_func
            renderPipelineDesriptor.fragmentFunction = frag_func
            renderPipelineDesriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
            self.renderPipelineState = try device?.makeRenderPipelineState(descriptor: renderPipelineDesriptor)
        } catch let e {
            fatalError("\(e)")
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
    }
}
