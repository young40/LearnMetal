//
//  MyMetalView.swift
//  08.MagicFlower
//
//  Created by 杨世玲 on 2018/9/6.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import MetalKit

class MyMetalView: MTKView {
    var cps: MTLComputePipelineState!
    var cmdQueue: MTLCommandQueue!
    
    var timer: Float = 0
    var timerBuffer: MTLBuffer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        initShader()
    }
    
    func initShader() {
        device = MTLCreateSystemDefaultDevice()!
        
        cmdQueue = device?.makeCommandQueue()
        
        framebufferOnly = false
        
        timerBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        
        do {
            let lib = device?.makeDefaultLibrary()
            
            let computer = lib?.makeFunction(name: "computer")!
            
            cps = try device?.makeComputePipelineState(function: computer!)
        } catch let e {
            fatalError()
        }
    }
    
    func update() {
        timer += 0.01
        
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
    }
    
    override func draw( _ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let drawable = currentDrawable!
        
        let cmdBuffer = cmdQueue.makeCommandBuffer()
        
        let cmdEncoder = cmdBuffer?.makeComputeCommandEncoder()
        cmdEncoder?.setTexture(drawable.texture, index: 0)
        cmdEncoder?.setComputePipelineState(cps)
        
        cmdEncoder?.setBuffer(timerBuffer, offset: 0, index: 1)
        update()
        
        let threadGroupPreGid = MTLSizeMake(8, 8, 1)
        let threadGroupCount = MTLSizeMake((drawable.texture.width+threadGroupPreGid.width-1)/threadGroupPreGid.width,
                                           (drawable.texture.height+threadGroupPreGid.height-1)/threadGroupPreGid.height
                                           , 1)
        
        cmdEncoder?.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadGroupPreGid)
        cmdEncoder?.endEncoding()
        
        cmdBuffer?.present(drawable)
        cmdBuffer?.commit()
    }
}
