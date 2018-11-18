//
//  Scene.swift
//  14.MoreModel
//
//  Created by 杨世玲 on 2018/11/18.
//  Copyright © 2018 杨世玲. All rights reserved.
//

import simd
import MetalKit

struct Light {
    var worldPosition = float3(0, 0, 0)
    var color = float3(0, 0, 0)
}

class Material {
    var specularColor = float3(1, 1, 1)
    var specularPower = Float(1)
    var baseColorTexture: MTLTexture?
}
