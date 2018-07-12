import Metal
import MetalKit
import PlaygroundSupport

class MyMetalView: MTKView {
    var vertexData: [Float]!
    var vertexBuffer: MTLBuffer!

    var renderPipelineState: MTLRenderPipelineState!

    var cmdQueue: MTLCommandQueue!

    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        self.device = device!

        self.initVertex()
        self.initShader()
        self.initRender()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func initVertex() {
        vertexData = [-0.7, -0.7, 0.0, 1.0,
                          0.7, -0.7, 0.0, 1.0,
                          0.0, 0.7, 0.0, 1.0]

        let vertexDataSize = vertexData.count * MemoryLayout<Float>.size

        vertexBuffer = (self.device?.makeBuffer(bytes: vertexData, length: vertexDataSize, options: []))!
    }

    public func initShader() {
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
        do {
            let library = try self.device?.makeLibrary(source: shader, options: nil)

            let vertex_func = library?.makeFunction(name: "vertex_func")
            let fragment_func = library?.makeFunction(name: "fragment_func")

            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()

            renderPipelineDescriptor.vertexFunction = vertex_func
            renderPipelineDescriptor.fragmentFunction = fragment_func

            renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm

            renderPipelineState = try self.device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }
        catch let e {
            print("\(e)")
            fatalError()
        }
    }

    public func initRender() {
        self.cmdQueue = self.device!.makeCommandQueue()
    }

    public override func draw(_ dirtyRect: NSRect) {
        let renderPassDescriptor = self.currentRenderPassDescriptor!
        let device = self.device!
        let drawable = self.currentDrawable
        
        let bgColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)

        renderPassDescriptor.colorAttachments[0].clearColor = bgColor

        let cmdBuffer = cmdQueue.makeCommandBuffer()!
        
        let cmdEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!

        cmdEncoder.setRenderPipelineState(self.renderPipelineState!)
        cmdEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        cmdEncoder.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
        cmdEncoder.endEncoding()
        
        cmdBuffer.present(drawable!)
        cmdBuffer.commit()
    }
}

let rect = CGRect(x: 0, y: 0, width: 800, height: 600)
let device = MTLCreateSystemDefaultDevice()

let view = MyMetalView(frame: rect, device: device)
PlaygroundPage.current.liveView = view
