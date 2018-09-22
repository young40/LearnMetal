//
//  MyMetalView.swift
//  12.Model
//
//  Created by 杨世玲 on 2018/9/21.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import MetalKit

class MyMetalView: MTKView {
    var cmdQueue: MTLCommandQueue!
    var renderPipelineState: MTLRenderPipelineState!
    
    var uniformsBuffer: MTLBuffer!
    var meshes: [MTKMesh]!
    var texture: MTLTexture!
    
    var depthStencilState: MTLDepthStencilState!
    let vertexDescriptor = MTLVertexDescriptor()
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1)
        self.colorPixelFormat = .bgra8Unorm
        
        initMetalObjs()
        initMatrixAndBuffers()
        initLibraryAndRenderPipleline()
        initAsset()
    }
    
    func initMetalObjs() {
        device = MTLCreateSystemDefaultDevice()!
        cmdQueue = device!.makeCommandQueue()
        
        self.depthStencilPixelFormat = MTLPixelFormat.depth32Float_stencil8
        
        let stencilDescriptor = MTLDepthStencilDescriptor()
        stencilDescriptor.depthCompareFunction = MTLCompareFunction.less
        stencilDescriptor.isDepthWriteEnabled = true
        
        depthStencilState = device?.makeDepthStencilState(descriptor: stencilDescriptor)
    }
    
    func initMatrixAndBuffers() {
        let scaled     = scalingMatrix(scale: 1)
        let rotated    = rotationMatrix(angle: 90, axis: float3(0, 1, 0))
        let translated = translationMatrix(position: float3(0, -10, 0))
        let modelMatrix = matrix_multiply(matrix_multiply(translated, rotated), scaled)
        
        let cameraPosition = float3(0, 0, -50)
        let viewMatrix  = translationMatrix(position: cameraPosition)
        
        let aspect = Float(drawableSize.width / drawableSize.height)
        let projMatrix = projectionMatrix(near: 0.1, far: 100, aspect: aspect, fovy: 1)
        
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        
        uniformsBuffer = device?.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
        
        let mvpMatrix = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        uniformsBuffer.contents().storeBytes(of: mvpMatrix, as: Uniforms.self)
    }
    
    func initLibraryAndRenderPipleline() {
        let lib = device?.makeDefaultLibrary()!
        
        let vert_func = lib?.makeFunction(name: "vert_func")
        let frag_func = lib?.makeFunction(name: "fragment_func")
        
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        
        vertexDescriptor.attributes[1].offset = 12
        vertexDescriptor.attributes[1].format = MTLVertexFormat.uchar4
        
        vertexDescriptor.attributes[2].offset = 16
        vertexDescriptor.attributes[2].format = MTLVertexFormat.half2
        
        vertexDescriptor.attributes[3].offset = 20
        vertexDescriptor.attributes[3].format = MTLVertexFormat.float
        
        vertexDescriptor.layouts[0].stride = 24
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        renderPipelineDescriptor.vertexFunction = vert_func
        renderPipelineDescriptor.fragmentFunction = frag_func
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
        renderPipelineDescriptor.stencilAttachmentPixelFormat = depthStencilPixelFormat
        
        do {
            renderPipelineState = try device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch let e {
            fatalError("\(e)")
        }
    }
    
    func initAsset() {
        let desc = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        
        var attribute = desc.attributes[0] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributePosition
        
        attribute = desc.attributes[1] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeColor
        
        attribute = desc.attributes[2] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeTextureCoordinate
        
        attribute = desc.attributes[3] as! MDLVertexAttribute
        attribute.name = MDLVertexAttributeOcclusionValue
        
        let mtkBufferAllocator = MTKMeshBufferAllocator(device: device!)
        
        let url = Bundle.main.url(forResource: "Farmhouse", withExtension: "obj")
        let asset = MDLAsset(url: url, vertexDescriptor: desc, bufferAllocator: mtkBufferAllocator)
        
        let loader = MTKTextureLoader(device: device!)
        let png = Bundle.main.url(forResource: "Farmhouse", withExtension: "png")
        texture = try! loader.newTexture(URL: png!, options: nil)
        
        let mesh = asset.object(at: 0) as? MDLMesh
        mesh?.generateAmbientOcclusionVertexColors(withQuality: 1, attenuationFactor: 0.98, objectsToConsider: [mesh!], vertexAttributeNamed: MDLVertexAttributeOcclusionValue)
        
        let ms = try! MTKMesh.newMeshes(asset: asset, device: device!)
        meshes = ms.metalKitMeshes
    }
}
