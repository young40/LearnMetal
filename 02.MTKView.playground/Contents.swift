import MetalKit
import PlaygroundSupport

class MyMetalView: MTKView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let renderPassDescriptor: MTLRenderPassDescriptor? = self.currentRenderPassDescriptor
        let drawable: CAMetalDrawable? = self.currentDrawable

        let bgColor: MTLClearColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
        renderPassDescriptor?.colorAttachments[0].clearColor = bgColor

        let command_queue: MTLCommandQueue? = self.device?.makeCommandQueue()

        let command_buffer: MTLCommandBuffer? = command_queue?.makeCommandBuffer()

        let command_encoder: MTLCommandEncoder? = command_buffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor!)
        command_encoder?.endEncoding()

        command_buffer?.present(drawable!)
        command_buffer?.commit()
    }
}

let rect = CGRect(x: 0, y: 0, width: 320, height: 480)
let device = MTLCreateSystemDefaultDevice()!

let view = MyMetalView(frame: rect, device: device)

PlaygroundPage.current.liveView = view
