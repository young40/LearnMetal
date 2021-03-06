//
//  MyShader.metal
//  11.TexturePlanet
//
//  Created by 杨世玲 on 2018/9/12.
//  Copyright © 2018 杨世玲. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float random(float2 p)
{
    return fract(sin(dot(p, float2(15.79, 81.93)) * 45678.9123));
}

float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float bottom = mix(random(i + float2(0)), random(i + float2(1.0, 0.0)), f.x);
    float top = mix(random(i + float2(0.0, 1.0)), random(i + float2(1)), f.x);
    float t = mix(bottom, top, f.y);
    return t;
}

float fbm(float2 uv)
{
    float sum = 0;
    float amp = 0.7;
    for(int i = 0; i < 4; ++i)
    {
        sum += noise(uv) * amp;
        uv += uv * 1.2;
        amp *= 0.4;
    }
    return sum;
}

kernel void computer(texture2d<float, access::write> output [[texture(0)]],
                     texture2d<float, access::sample> input [[texture(1)]],
                     constant float &timer [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    
    float2 uv = float2(gid) / float2(width, height);
    
    uv = uv*2 - 1;
    
    float radius = 0.5;
    
    float distance = length(uv) - radius;
    
    float4 color = input.read(gid);
    gid.y = input.get_height() - gid.y;
//    output.write(color, gid);
    
//    output.write((distance < 0 ? color : float4(0)), gid);
    
    uv = uv * 2;
    radius = 1;
    
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear);
    
    float3 norm = float3(uv, sqrt(1.0 - dot(uv, uv)));
    float pi = 3.14;
    float s = atan2( norm.z, norm.x) / (2*pi);

    float t = asin( norm.y ) / (2*pi);
    t += 0.5;
    
    color = input.sample(textureSampler, float2(s + timer * 0.1, t));
    output.write((distance < 0 ? color : float4(0)), gid);
}
