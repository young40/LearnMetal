//
//  MyShader.metal
//  10.Noise
//
//  Created by 杨世玲 on 2018/9/11.
//  Copyright © 2018 杨世玲. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void computer(texture2d<float, access::write> output [[texture(0)]],
                     uint2 gid [[thread_position_in_grid]]) {
    output.write(float4(0.3, 0.4, 0.5, 1), gid);
}
