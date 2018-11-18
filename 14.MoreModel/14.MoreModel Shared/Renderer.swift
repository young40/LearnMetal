//
//  Renderer.swift
//  14.MoreModel Shared
//
//  Created by 杨世玲 on 2018/9/28.
//  Copyright © 2018 杨世玲. All rights reserved.
//

// Our platform independent renderer class

import Metal
import MetalKit
import ModelIO
import simd

enum RendererError: Error {
    case badVertexDescriptor
}

struct VertexUniforms {
    var modelViewMatrix: float4x4
    var projectionMatrix: float4x4
    var normalMatrix: float3x3
}

struct FragmentUniforms {
    var cameraWorldPosition = float3(0, 0, 0)
    var ambientLightColor = float3(0, 0, 0)
    var specularColor = float3(1, 1, 1)
    var specularPower = Float(1)
    var light0 = Light()
    var light1 = Light()
    var light2 = Light()
}

class Renderer: NSObject, MTKViewDelegate {
    public let device: MTLDevice
    let mtkView: MTKView
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState!
//    var depthState: MTLDepthStencilState
//    var colorMap: MTLTexture
    
    var projectionMatrix: matrix_float4x4 = matrix_float4x4()
    
    var rotation: Float = 0
    
    var meshes: [MTKMesh] = []
    
    var vertexDescriptor: MTLVertexDescriptor!
    
    var time: Float = 0
    
    let depthStencilState: MTLDepthStencilState
    
    var baseColorTexture: MTLTexture!
    let samplerState: MTLSamplerState
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        guard let queue = self.device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        
        metalKitView.depthStencilPixelFormat = MTLPixelFormat.depth32Float
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
//        metalKitView.sampleCount = 1
        
        self.mtkView = metalKitView
        self.depthStencilState = Renderer.buildDepthStencilState(device: device)
        self.samplerState = Renderer.buildSamplerState(device: device)
        
        super.init()
        
        loadResource()
        buildPipeline()
    }
    
    func loadResource() {
        let modelUrl = Bundle.main.url(forResource: "teapot", withExtension: "obj")
        
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,          format: .float3, offset: 0,                          bufferIndex: 0)
        vertexDescriptor.attributes[1] = MDLVertexAttribute(name: MDLVertexAttributeNormal,            format: .float3, offset: MemoryLayout<Float>.size*3, bufferIndex: 0)
        vertexDescriptor.attributes[2] = MDLVertexAttribute(name: MDLVertexAttributeTextureCoordinate, format: .float2, offset: MemoryLayout<Float>.size*6, bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: MemoryLayout<Float>.size * 8)
        
        self.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)

        let bufferAllocator = MTKMeshBufferAllocator(device: self.device)
        
        let asset = MDLAsset(url: modelUrl, vertexDescriptor: vertexDescriptor, bufferAllocator: bufferAllocator)
        
        do {
            (_, meshes) = try MTKMesh.newMeshes(asset: asset, device: device)
        } catch {
            fatalError("can't get meshes from model")
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        let options: [MTKTextureLoader.Option : Any] = [MTKTextureLoader.Option.generateMipmaps : true,
                                                         MTKTextureLoader.Option.SRGB : true]
        do {
            let url = Bundle.main.url(forResource: "tiles_baseColor", withExtension: "jpg")
           baseColorTexture = try textureLoader.newTexture(URL: url!, options: options)
        } catch {
            print(error.localizedDescription)
            fatalError()
        }
    }
    
    func buildPipeline() {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("load default library error.")
        }
        
        let vertexFunction   = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexFunction   = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat      = self.mtkView.depthStencilPixelFormat
//        pipelineDescriptor.stencilAttachmentPixelFormat    = self.mtkView.depthStencilPixelFormat
        
        pipelineDescriptor.vertexDescriptor = self.vertexDescriptor
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print(error.localizedDescription)
            fatalError("create render fail: \(error)")
        }
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor,
           let drawable = view.currentDrawable
        {
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            
            time += 1 / Float(mtkView.preferredFramesPerSecond)
            let angle = time
            let modelMatrix = float4x4(rotationAbout: float3(0, 1, 0), by: angle) *
                              float4x4(scaleBy: 2)
            
            let cameraWorldPosition = float3(0, 0, 2)
            let viewMatrix = float4x4(translationBy: float3(0, 0, -2))
            let modelViewMatrix = viewMatrix * modelMatrix
            let aspectRatio = Float(view.drawableSize.width / view.drawableSize.height)
            let projectionMatrix = float4x4(perspectiveProjectionFov: Float.pi / 3, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 100)
            
            var uniforms = VertexUniforms(modelViewMatrix: modelViewMatrix,
                                       projectionMatrix: projectionMatrix,
                                       normalMatrix: modelMatrix.normalMatrix)
            
            commandEncoder.setVertexBytes(&uniforms, length: MemoryLayout<VertexUniforms>.size, index: 1)
            
            let material = Material()
            material.specularPower = 200
            material.specularColor = float3(0.8, 0.8, 0.8)
            
            
            let light0 = Light(worldPosition: float3(2, 2, 2), color: float3(1, 0, 0))
            let light1 = Light(worldPosition: float3(-2, 2, 2), color: float3(0, 1, 0))
            let light2 = Light(worldPosition: float3(0, -2, 2), color: float3(0, 0, 1))
            
            var fragmentUniforms = FragmentUniforms(cameraWorldPosition: cameraWorldPosition,
                                                    ambientLightColor: float3(0.1, 0.1, 0.1),
                                                    specularColor: material.specularColor,
                                                    specularPower: material.specularPower,
                                                    light0: light0,
                                                    light1: light1,
                                                    light2: light2)
            
            commandEncoder.setFragmentBytes(&fragmentUniforms, length: MemoryLayout<FragmentUniforms>.size, index: 0)
            
            commandEncoder.setFragmentTexture(baseColorTexture, index: 0)
            commandEncoder.setFragmentSamplerState(samplerState, index: 0)
            
            commandEncoder.setDepthStencilState(depthStencilState)
            commandEncoder.setRenderPipelineState(pipelineState)
            
            for mesh in meshes
            {
                let vertexBuffer = mesh.vertexBuffers.first!
                commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: 0)
                
                for submesh in mesh.submeshes
                {
                    let indexBuffer = submesh.indexBuffer
                    commandEncoder.drawIndexedPrimitives(type:       submesh.primitiveType,
                                                         indexCount: submesh.indexCount,
                                                         indexType:  submesh.indexType,
                                                         indexBuffer:       indexBuffer.buffer,
                                                         indexBufferOffset: indexBuffer.offset)
                }
            }
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState
    {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        
        return device.makeDepthStencilState(descriptor: depthStencilDescriptor)!
    }
    
    static func buildSamplerState(device: MTLDevice) -> MTLSamplerState
    {
        let samplerDescriptor = MTLSamplerDescriptor()
        
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.mipFilter = .linear
        
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }
}
