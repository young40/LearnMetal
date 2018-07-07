import Metal
import MetalKit
import PlaygroundSupport

class MyMetalView: MTKView {
    public override func draw(_ dirtyRect: NSRect) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        let device = self.device
        let drawable = self.currentDrawable
        
        let bgColor = MTLClearColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1)
        
        renderPassDescriptor.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptor.colorAttachments[0].clearColor = bgColor
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        
        let cmdQueue = device?.makeCommandQueue()
        
        let cmdBuffer = cmdQueue?.makeCommandBuffer()
        
        let cmdEncoder = cmdBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        cmdEncoder?.endEncoding()
        
        cmdBuffer?.present(drawable!)
        
        cmdBuffer?.commit()
    }
}

let rect = CGRect(x: 0, y: 0, width: 320, height: 480)
let device = MTLCreateSystemDefaultDevice()

let view = MyMetalView(frame: rect, device: device)
PlaygroundPage.current.liveView = view
