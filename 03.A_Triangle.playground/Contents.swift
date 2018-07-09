import Metal
import MetalKit
import PlaygroundSupport

class MyMetalView: MTKView {
    var vertexBuffer: MTLBuffer!
    var renderPipelineState: MTLRenderPipelineState!

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        self.device = device

        self.initVertex()
        self.initShader()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func initVertex() {
        let vertexData = [-0.7, -0.7, 0.0, 1.0,
                          0.7, -0.7, 0.0, 1.0,
                          0.0, 0.7, 0.0, 1.0]

        let vertexDataSize = vertexData.count * MemoryLayout<Float>.size

        vertexBuffer = (self.device?.makeBuffer(bytes: vertexData, length: vertexDataSize, options: []))!
    }

    public func initShader() {

    }

    public override func draw(_ dirtyRect: NSRect) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let device = self.device
        let drawable = self.currentDrawable
        
        let bgColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
        
        renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptor.colorAttachments[0].clearColor = bgColor
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        
        let cmdQueue = device?.makeCommandQueue()



        let shader = """
#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float4 postion [[position]];
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          uint vid [[vertex_id]] ){
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return float4(0.7, 1, 1, 1);
}
"""
        var renderPiplineState: MTLRenderPipelineState?

        do {
            let lib = try device?.makeLibrary(source: shader, options: nil)

            let vertex_func = lib?.makeFunction(name: "vertex_func")
            let fragment_func = lib?.makeFunction(name: "fragment_func")

            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

            renderPipelineDescriptor.vertexFunction = vertex_func
            renderPipelineDescriptor.fragmentFunction = fragment_func

            renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm

            renderPiplineState = try device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }
        catch let e {
            print("xxxx")
            print("\(e)")
            fatalError()
        }

        let cmdBuffer = cmdQueue?.makeCommandBuffer()
        
        let cmdEncoder = cmdBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        cmdEncoder?.setRenderPipelineState(renderPiplineState!)
        cmdEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        cmdEncoder?.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)

        cmdEncoder?.endEncoding()
        
        cmdBuffer?.present(drawable!)
        
        cmdBuffer?.commit()
    }
}

let rect = CGRect(x: 0, y: 0, width: 320, height: 480)
let device = MTLCreateSystemDefaultDevice()

let view = MyMetalView(frame: rect, device: device)
PlaygroundPage.current.liveView = view
