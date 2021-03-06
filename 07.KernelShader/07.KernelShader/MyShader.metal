//
//  MyShader.metal
//  07.KernelShader
//
//  Created by 杨世玲 on 2018/9/4.
//  Copyright © 2018 杨世玲. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float dist(float2 point, float2 center, float radius)
{
    return length(point - center) - radius;
}

kernel void computer(texture2d<float, access::write> output [[texture(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    output.write(float4(0.3, 0.4, 0.5, 1), gid);
    
    int width = output.get_width();
    int height = output.get_height();
    float red = float(gid.x) / float(width);
    float green = float(gid.y) / float(height);
    float2 uv = float2(gid) / float2(width, height);
    
    uv = uv*2.0 - 1.0;
    
    float distToCircel = dist(uv, float2(0), 0.5);
    float distToCircel2 = dist(uv, float2(-0.1, 0.1), 0.5);
    bool inside = distToCircel2 < 0;
    
    output.write(inside ? float4(0): float4(1, 0.7, 0, 1) * (1 - distToCircel), gid);
}
