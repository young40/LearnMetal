//
//  MyMetalView.swift
//  10.Noise
//
//  Created by 杨世玲 on 2018/9/11.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import MetalKit

class MyMetalView: MTKView {
    var cmdQueue: MTLCommandQueue!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
