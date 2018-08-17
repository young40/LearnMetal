//
//  MyShader.metal
//  05.Transformations
//
//  Created by Peter Young on 2018/8/5.
//  Copyright © 2018 Peter Young. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniform {
    float4x4 modelMatrix;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant Uniform &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelMatrix;
    
    Vertex in = vertices[vid];
    
    Vertex out;
    
    out.position = matrix * float4(in.position);
    out.color = in.color;
    
    return out;
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}
