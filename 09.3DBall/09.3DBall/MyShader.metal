//
//  MyShader.metal
//  09.3DBall
//
//  Created by 杨世玲 on 2018/9/8.
//  Copyright © 2018 杨世玲. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void computer(texture2d<float, access::write> output [[texture(0)]],
                     constant float &timer [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    
    float2 uv = float2(gid) / float2(width, height);
    
    uv = uv*2 - 1;
    
    float radius = 0.5;
    
    float distance = length(uv) - radius;
    
    float planet = float(sqrt(radius * radius - uv.x * uv.x - uv.y * uv.y));
    planet /= radius;
    output.write(distance < 0 ? float4(planet) : float4(0), gid);
    
    
    float3 normal = normalize(float3(uv.x, uv.y, planet));
    output.write(distance < 0 ? float4(float3(normal), 1) : float4(0), gid);
    
    
//    float3 source = normalize(float3(-1, 0, 1));
    float3 source = normalize(float3(cos(timer), sin(timer), 1));

    float light = dot(normal, source);
    output.write(distance < 0 ? float4(float3(light), 1) : float4(0), gid); 
    
//    output.write(float4(0.3, 0.4, 0.5, 1), gid);
}
