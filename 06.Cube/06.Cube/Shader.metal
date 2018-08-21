//
//  Shader.metal
//  06.Cube
//
//  Created by 杨世玲 on 2018/8/19.
//  Copyright © 2018 杨世玲. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                        constant Uniforms &uniforms [[buffer(1)]],
                        uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelViewProjectionMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    
    out.position = matrix * float4(in.position);
    out.color = in.color;
    
    return out;
}

fragment half4 fragment_func(Vertex vert [[stage_in]]) {
    return half4(vert.color);
}
