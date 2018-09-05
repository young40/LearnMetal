//
//  MyMetalView.swift
//  07.KernelShader
//
//  Created by 杨世玲 on 2018/9/4.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import MetalKit

class MyMetalView: MTKView {
    
    var queue: MTLCommandQueue!
    var cps: MTLComputePipelineState!
    
//    override public init(frame frameRect: CGRect, device: MTLDevice?) {
//        super.init(frame: frameRect, device: device)
//
//    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()
        
        initShader()
    }
    
    func initShader() {
        queue = device?.makeCommandQueue()
        
        let lib = device?.makeDefaultLibrary()
        
        let kernel = lib?.makeFunction(name: "computer")!
        
        do {
            cps = try device?.makeComputePipelineState(function: kernel!)
        } catch let e {
            fatalError(e as! String)
        }
        
        framebufferOnly = false
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let drawable = self.currentDrawable!
        
        let commandBuffer = queue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(cps)
        commandEncoder?.setTexture(drawable.texture, index: 0)
        
        let threadGroupPreGid = MTLSize(width: 2, height: 2, depth: 1)
        let threadGroupCount = MTLSize(width: (drawable.texture.width+threadGroupPreGid.width-1)/threadGroupPreGid.width,
                                       height: (drawable.texture.height + threadGroupPreGid.height-1)/threadGroupPreGid.height, depth: 1)
        
        commandEncoder?.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadGroupPreGid)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
