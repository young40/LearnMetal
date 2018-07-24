import MetalKit
import PlaygroundSupport

class MyMetalView: MTKView {
    private var vertexData: [Float]!
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
        self.vertexData = [-0.7, -0.7, 0, 1,
                           0.7, -0.7, 0, 1,
                           0, 0.7, 0, 1]
    }
    
    
}


let rect = CGRect(x: 0, y: 0, width: 800, height: 600)
let device = MTLCreateSystemDefaultDevice()

let view = MyMetalView(frame: rect, device: device)
PlaygroundPage.current.liveView = view
