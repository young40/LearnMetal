import MetalKit
import PlaygroundSupport

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class MyMetalView: MTKView {
    private var vertexData: [Vertex]!
    private var vertexBuffer: MTLBuffer!
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var cmdQueue: MTLCommandQueue!
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        self.initVertex()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func initVertex() {
        self.vertexData = [Vertex(position: [   0,  0.7, 0, 1], color: [1, 0, 0, 1]),
                           Vertex(position: [-0.7, -0.7, 0, 1], color: [0, 1, 0, 1]),
                           Vertex(position: [ 0.7,  0.7, 0, 1], color: [0, 0, 1, 0])]
        
        let vertexDataSize = MemoryLayout<Vertex>.size * self.vertexData.count
        
        self.vertexBuffer = self.device?.makeBuffer(bytes: self.vertexData, length: vertexDataSize, options: [])
    }
    
    public func initShader() {
        let shaderStr = """
#include <metal_stdlib>

"""
    }
}


let rect = CGRect(x: 0, y: 0, width: 800, height: 600)
let device = MTLCreateSystemDefaultDevice()

let view = MyMetalView(frame: rect, device: device)
PlaygroundPage.current.liveView = view
