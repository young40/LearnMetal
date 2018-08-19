//
//  MathUtils.swift
//  06.Cube
//
//  Created by 杨世玲 on 2018/8/19.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import simd

struct Vertex {
    var position: vector_float4
    var color: vector_float4
    
    init(pos: vector_float4, col: vector_float4) {
        position = pos
        color = col
    }
}
