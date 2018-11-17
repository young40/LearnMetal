//
//  Shaders.metal
//  14.MoreModel Shared
//
//  Created by 杨世玲 on 2018/9/28.
//  Copyright © 2018 杨世玲. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 position [[attribute(VertexAttributePosition)]];
    float2 texCoord [[attribute(VertexAttributeTexcoord)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> colorMap     [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);

    half4 colorSample   = colorMap.sample(colorSampler, in.texCoord.xy);

    return float4(colorSample);
}

struct VertexIn {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
    float4 eyeNormal;
    float4 eyePosition;
    float2 texCoords;
};

struct MyUniforms {
    float4x4 modelViewMatrix;
    float4x4 projectionMatrix;
    float3x3 normalMatrix;
};

constant float3 ambientIntensity = 0.1;
constant float3 lightPosition = (2, 2, 2);
constant float3 lightColor = (1, 1, 1);
constant float3 baseColor(1.0, 0, 0);
constant float3 worldCameraPostion(0, 0, 2);
constant float  specularPower = 200;

vertex VertexOut vertex_main(VertexIn vertexIn [[stage_in]],
                             constant MyUniforms &uniforms [[buffer(1)]])
{
    VertexOut vertexOut;
    
    float4 worldPosition = uniforms.modelViewMatrix * float4(vertexIn.position, 1);
    
    vertexOut.position    = uniforms.projectionMatrix * uniforms.modelViewMatrix * float4(vertexIn.position, 1);
    vertexOut.worldPosition = worldPosition.xyz;
    vertexOut.worldNormal = uniforms.normalMatrix * vertexIn.normal;
    vertexOut.eyeNormal   = uniforms.modelViewMatrix * float4(vertexIn.normal, 0);
    vertexOut.eyePosition = uniforms.modelViewMatrix * float4(vertexIn.position, 1);
    vertexOut.texCoords   = vertexIn.texCoords;
    
    return vertexOut;
}

fragment float4 fragment_main(VertexOut fragmentIn [[stage_in]])
{
    float3 N = normalize(fragmentIn.worldNormal.xyz);
    float3 L = normalize(lightPosition - fragmentIn.worldPosition.xyz);
    
    float3 diffuseIntensity = saturate(dot(N, L));
    
    float3 V = normalize(worldCameraPostion - fragmentIn.worldPosition);
    float3 H = normalize(L + V);
    float specularBase = saturate(dot(N, H));
    float specularIntensity = powr(specularBase, specularPower);
    float3 specularColor = specularIntensity * lightColor;
    
    float3 finalColor = saturate(ambientIntensity + diffuseIntensity) * lightColor * baseColor
                        + specularColor;
    
    return float4(finalColor, 1);
}
