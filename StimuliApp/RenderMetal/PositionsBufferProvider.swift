//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

class PositionsBufferProvider: NSObject {


    let inflightBuffersCount: Int
    private var positionsBuffers: [MTLBuffer]
    private var avaliableBufferIndex: Int = 0
    var semaphore: DispatchSemaphore


    init(device:MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {

        self.inflightBuffersCount = inflightBuffersCount
        positionsBuffers = [MTLBuffer]()
        semaphore = DispatchSemaphore(value: inflightBuffersCount)

        for _ in 0 ... inflightBuffersCount - 1 {
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            positionsBuffers.append(uniformsBuffer!)
        }
    }

    deinit {
        for _ in 0 ... self.inflightBuffersCount{
            self.semaphore.signal()
        }
    }

    func nextPositionsBuffer() -> MTLBuffer {

        let buffer = positionsBuffers[avaliableBufferIndex]
        let bufferPointer = buffer.contents()

        memcpy(bufferPointer, &DataTask.selectedObjects, DataTask.selectedObjects.count * MemoryLayout<Float>.stride)

        avaliableBufferIndex += 1
        if avaliableBufferIndex == inflightBuffersCount {
            avaliableBufferIndex = 0
        }

        return buffer
    }
}
