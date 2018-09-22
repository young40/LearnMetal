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
}
