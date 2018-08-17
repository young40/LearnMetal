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

struct Matrix {
    var m: [Float]
    
    init() {
        m = [1, 0, 0, 0,
             0, 1, 0, 0,
             0, 0, 1, 0,
             0, 0, 0, 1]
    }
    
    func translationMatrix(_ matrix: Matrix, _ position: float3) -> Matrix {
        var matrix = matrix
        matrix.m[12] = position.x
        matrix.m[13] = position.y
        matrix.m[14] = position.z
        return matrix
    }
    func scalingMatrix(_ matrix: Matrix, _ scale: Float) -> Matrix {
        var matrix = matrix
        matrix.m[0] = scale
        matrix.m[5] = scale
        matrix.m[10] = scale
        matrix.m[15] = 1.0
        return matrix
    }
    func rotationMatrix(_ matrix: Matrix, _ rot: float3) -> Matrix {
        var matrix = matrix
        matrix.m[0] = cos(rot.y) * cos(rot.z)
        matrix.m[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
        matrix.m[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)
        matrix.m[1] = cos(rot.y) * sin(rot.z)
        matrix.m[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
        matrix.m[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z)
        matrix.m[2] = -sin(rot.y)
        matrix.m[6] = cos(rot.y) * sin(rot.x)
        matrix.m[10] = cos(rot.x) * cos(rot.y)
        matrix.m[15] = 1.0
        return matrix
    }
    func modelMatrix(_ matrix: Matrix) -> Matrix {
        var matrix = matrix
        matrix = rotationMatrix(matrix, float3(0.0, 0.0, 0.7))
        matrix = scalingMatrix(matrix, 0.7)
        matrix = translationMatrix(matrix, float3(0.0, 0.5, 0.0))
        return matrix
    }
}

class MyMetalView: MTKView {
    private var vertexData: [Vertex]!
    private var vertexBuffer:  MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    
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
        
        self.uniformBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size*16, options: [])
        let bufferPointer = self.uniformBuffer.contents()
        memcpy(bufferPointer, Matrix().modelMatrix(Matrix()).m, MemoryLayout<Float>.size*16)
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
        
        cmdEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, index: 1)
        
        cmdEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)

        cmdEncoder.endEncoding()

        cmdBuffer.present(drawable)
        cmdBuffer.commit()
    }
}
