import Cocoa

//首先需要引入Metal
import Metal

// 获取默认设备
// 如果有多个GPU, 默认会获取到High Power的设备
var defaultDevice = MTLCreateSystemDefaultDevice()

guard defaultDevice != nil else {
    fatalError("无法获取支持Metal的设备")
}

let device = defaultDevice!

func showDevice(device: MTLDevice) {
    print("----------我们要展示一个Metal了-----------")
    print("设备名称:      \t\(device.name)")
    print("是否是低性能:   \t\(device.isLowPower  ? "是" : "否" )")
    print("是否接显示器:   \t\(device.isHeadless  ? "否" : "是" )")
    print("设置是否可移除: \t\(device.isRemovable ? "是" : "否" )")
    print("设备注册ID:    \t\(device.registryID)")
}

showDevice(device: device)

// 当然我们也可以获取到所有的设备
let devices = MTLCopyAllDevices()

// 遍历所有设备
for device in devices {
    showDevice(device: device)
}
