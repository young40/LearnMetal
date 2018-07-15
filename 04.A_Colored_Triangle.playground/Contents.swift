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

     override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        self.device = device
        self.initBuffer()
        self.initShader()
        self.initRender()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initBuffer() {
        vertexData = [Vertex(position: [   0,  0.7, 0, 1] , color: [1, 0, 0, 1]),
                      Vertex(position: [-0.7, -0.7, 0, 1] , color: [0, 1, 0, 1]),
                      Vertex(position: [ 0.7, -0.7, 0, 1] , color: [0, 0, 1, 1])]

        let vertexDataSize = vertexData.count * MemoryLayout<Vertex>.size

        vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: vertexDataSize, options: [])
    }

    func initShader() {
        let shaderStr = """
#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          uint vid [[vertex_id]]) {
    return vertices[vid];
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}
"""

        do {
            let library = try self.device?.makeLibrary(source: shaderStr, options: nil)

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

    func initRender() {
        self.cmdQueue = self.device?.makeCommandQueue()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let renderPassDescriptor = self.currentRenderPassDescriptor
        let drawable = self.currentDrawable

        let bgColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)

        renderPassDescriptor?.colorAttachments[0].clearColor = bgColor

        let cmdBuffer = cmdQueue.makeCommandBuffer()!

        let cmdEncoder = cmdBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)!

        cmdEncoder.setRenderPipelineState(self.renderPipelineState)
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
