//
//  MyMetalView.swift
//  11.TexturePlanet
//
//  Created by 杨世玲 on 2018/9/12.
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
        
        framebufferOnly = false
        
        cmdQueue = device?.makeCommandQueue()
        
        let lib = device?.makeDefaultLibrary()
        
        let computer = lib?.makeFunction(name: "computer")!
        
        do {
            cps = try device?.makeComputePipelineState(function: computer!)
        } catch let e {
            fatalError("\(e)")
        }
        
        timerBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size, options: [])
    }
    
    func update() {
        timer += 0.01
        let timerPointer = timerBuffer.contents()
        memcpy(timerPointer, &timer, MemoryLayout<Float>.size)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let drawable = currentDrawable!
        
        let cmdBuffer = cmdQueue.makeCommandBuffer()!
        
        let cmdEncoder = cmdBuffer.makeComputeCommandEncoder()!
        
        cmdEncoder.setTexture(drawable.texture, index: 0)
        cmdEncoder.setComputePipelineState(cps)
        
        cmdEncoder.setBuffer(timerBuffer, offset: 0, index: 0)
        update()
        
        let threadPreGid = MTLSizeMake(8, 8, 1)
        let threadCount  = MTLSizeMake((drawable.texture.width + threadPreGid.width - 1) / threadPreGid.width,
                                       (drawable.texture.height + threadPreGid.height - 1) / threadPreGid.height
            , 1)
        
        cmdEncoder.dispatchThreadgroups(threadCount, threadsPerThreadgroup: threadPreGid)
        
        cmdEncoder.endEncoding()
        
        cmdBuffer.present(drawable)
        cmdBuffer.commit()
    }
}
