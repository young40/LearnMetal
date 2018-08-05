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

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}
