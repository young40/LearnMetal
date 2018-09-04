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
        
        let x = drawable.texture.width
        let y = drawable.texture.height
        
        let commandBuffer = queue.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(cps)
        commandEncoder?.setTexture(drawable.texture, index: 0)
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width/threadGroupCount.width,
                                       drawable.texture.height/threadGroupCount.height, 1)
        commandEncoder?.dispatchThreads(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
