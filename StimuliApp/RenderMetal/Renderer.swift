//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import MetalKit

class Renderer: NSObject {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var displayRender: DisplayRender?
    var view: MTKView?

    var objectPipelineStates: [MTLComputePipelineState?] = []
    var computePipelineStates: [MTLComputePipelineState?] = []

    var dotBuffer: MTLBuffer?
    var dotBuffer1: MTLBuffer?
    var positionsBufferProviders: [PositionsBufferProvider] = []

    var objectThreadsPerGroupX: [Int] = Array(repeating: 1, count: Constants.numberOfObjectKernels + 1)
    var objectThreadsPerGroupY: [Int] = Array(repeating: 1, count: Constants.numberOfObjectKernels + 1)



    // MARK: - Init
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!

        super.init()

        let library = device.makeDefaultLibrary()

        for stimulus in StimuliType.allCases where stimulus.style != .nonMetal {
            objectPipelineStates.append(buildPipelineState(device: device,
                                                           library: library,
                                                           functionName: stimulus.name))
        }

        objectPipelineStates.append(buildPipelineState(device: device, library: library, functionName: "clean"))


        for name in MetalLibrary.compute {
            computePipelineStates.append(buildPipelineState(device: device, library: library, functionName: name))
        }
    }

    // MARK: - Functions
    private func buildPipelineState(device: MTLDevice, library: MTLLibrary?,
                                    functionName: String) -> MTLComputePipelineState {

        let function = library?.makeFunction(name: functionName)
        let pipelineState: MTLComputePipelineState
        do {
            pipelineState = try device.makeComputePipelineState(function: function!)
        } catch let error as NSError {
            fatalError("error: \(error.localizedDescription)")
        }
        return pipelineState
    }

    private func createImageTextures() -> [MTLTexture] {
        var textures: [MTLTexture] = []

        for element in Task.shared.images {
            let texture = AppUtility.createTexture(from: element.image, device: device)
            textures.append(texture)
        }
        return textures
    }

    private func createEmptyTextures() -> [MTLTexture] {
        let texture = AppUtility.createTexture(device: device, width: 1, height: 1)
        return Array(repeating: texture, count: Constants.maxNumberOfMetalStimuli)
    }

    private func updateObjectTextures() {
        for i in 0 ..< DataTask.metalValues.count {
            let width = DataTask.objectSizeMax[i].x
            let height = DataTask.objectSizeMax[i].y
            DataTask.objectTextures[i] = AppUtility.createTexture(device: device, width: width, height: height)
        }
    }

    func createThreadsBuffersAndTextures() {

        guard let drawable = view?.currentDrawable else { return }

        DataTask.imageTextures = createImageTextures()
        DataTask.objectTextures = createEmptyTextures()

        let width = drawable.texture.width
        let height = drawable.texture.height

        for sectionTask in Task.shared.sectionTasks {
            for sceneTask in sectionTask.sceneTasks {
                for trial in 0 ..< sceneTask.numberOfTrials {
                    sceneTask.backgroundFloats[trial][BackGroundValues.screenWidth] = Float(width)
                    sceneTask.backgroundFloats[trial][BackGroundValues.screenHeight] = Float(height)
                }
            }
        }

        Task.shared.semiWidth = Float(width) / 2
        Task.shared.semiHeight = Float(height) / 2

        for i in 0 ..< Constants.numberOfObjectKernels + 1 { // all the object kernels + clean
            guard let stimulusPipelineState = objectPipelineStates[i] else { return }

            objectThreadsPerGroupX[i] = stimulusPipelineState.threadExecutionWidth
            objectThreadsPerGroupY[i] = stimulusPipelineState.maxTotalThreadsPerThreadgroup /
                objectThreadsPerGroupX[i]
        }


        for i in 0 ..< Constants.numberOfComputeKernels {
            guard let computePipelineState = computePipelineStates[i] else { return }

            Task.shared.computeThreadsPerGroupX[i] = computePipelineState.threadExecutionWidth
            Task.shared.computeThreadsPerGroupY[i] = computePipelineState.maxTotalThreadsPerThreadgroup /
                Task.shared.computeThreadsPerGroupX[i]

            Task.shared.computeNumberOfGroupsX[i] = (width + Task.shared.computeThreadsPerGroupX[i] - 1) /
                Task.shared.computeThreadsPerGroupX[i]
            Task.shared.computeNumberOfGroupsY[i] = (height + Task.shared.computeThreadsPerGroupY[i] - 1) /
                Task.shared.computeThreadsPerGroupY[i]

            Task.shared.computeNumberOfGroups[i] = Task.shared.computeNumberOfGroupsX[i] *
                Task.shared.computeNumberOfGroupsY[i]

            let max = Constants.maxNumberOfMetalStimuli * Task.shared.computeNumberOfGroups[i] * 3

            let positionsBufferProvider = PositionsBufferProvider(device: device,
                                                                 inflightBuffersCount: 3,
                                                                 sizeOfUniformsBuffer: max * MemoryLayout<Float>.stride)

            positionsBufferProviders.append(positionsBufferProvider)
        }
        let max = Constants.maxNumberOfDots * Constants.numberOfDotsFloats

        dotBuffer = device.makeBuffer(length: max * MemoryLayout<Float>.stride, options: [])
        dotBuffer1 = device.makeBuffer(length: max * MemoryLayout<Float>.stride, options: [])

        if let dotBuffer = dotBuffer {
            memcpy(dotBuffer.contents(),
                   &Task.shared.dots,
                   Task.shared.dots.count * MemoryLayout<Float>.stride)
        }
        if let dotBuffer1 = dotBuffer1 {
            memcpy(dotBuffer1.contents(),
                   &Task.shared.dots1,
                   Task.shared.dots1.count * MemoryLayout<Float>.stride)
        }

        Task.shared.firstUpdateBuffer()
        updateObjectTextures()
    }
}

// MARK: - Extension Renderer
extension Renderer: MTKViewDelegate {

    private func updateFrameControl() {
        guard Task.shared.sceneTask.calculateLongFrames else { return }
        guard let displayRender = displayRender else { return }
        Task.shared.actualFrameTime = CACurrentMediaTime()
        let elapsed = Task.shared.actualFrameTime - Task.shared.previousFrameTime
        Task.shared.previousFrameTime = Task.shared.actualFrameTime

        if elapsed > Double(1.25 * Flow.shared.settings.delta) && !displayRender.inactiveToMeasureFrame
            && !displayRender.responded {
            let longFrame = LongFrame(scene: Task.shared.sceneTask.name,
                                      trial: Task.shared.sectionTask.currentTrial + 1,
                                      frame: displayRender.timeInFrames,
                                      duration: elapsed)
            Task.shared.longFrames.append(longFrame)
        }
        Task.shared.totalNumberOfFrames += 1
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {

        updateFrameControl()

        let positionsBufferProvider = positionsBufferProviders[Task.shared.computeNumber]

        _ = positionsBufferProvider.semaphore.wait(timeout: .distantFuture)

         guard let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
            else { return }

        commandBuffer.addCompletedHandler { (_) in
          positionsBufferProvider.semaphore.signal()
        }

        _ = displayRender?.update()

        updateObjectTextures()


        var dotPosition = 0

        for i in 0 ..< DataTask.metalValues.count {

            if DataTask.activatedBools[i] {
                let type = DataTask.metalValues[i][MetalValues.type].toInt

                switch StimuliType.allCases[type].style {
                case .metalRegular:
                    commandEncodeObject(commandBuffer: commandBuffer,
                                        commandEncoder: commandEncoder,
                                        position: i,
                                        type: type)
                case .dots:
                    commandEncodeClean(commandBuffer: commandBuffer,
                                      commandEncoder: commandEncoder,
                                      position: i,
                                      type: Constants.numberOfObjectKernels)
                    commandEncodeDots(commandBuffer: commandBuffer,
                                      commandEncoder: commandEncoder,
                                      position: i,
                                      type: type,
                                      dotPosition: dotPosition)
                    dotPosition = 1
                case .image:
                    let imageNumber = DataTask.images[i]
                    let image = DataTask.imageTextures[imageNumber]
                    commandEncodeImage(commandBuffer: commandBuffer,
                                       commandEncoder: commandEncoder,
                                       position: i,
                                       image: image,
                                       type: type)

                case .nonMetal:
                    break
                }
            }
        }

        commandEncodeCompute(commandBuffer: commandBuffer,
                             commandEncoder: commandEncoder,
                             positionsBufferProvider: positionsBufferProvider,
                             texture0: drawable.texture)

        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    private func commandEncodeObject(commandBuffer: MTLCommandBuffer,
                                     commandEncoder: MTLComputeCommandEncoder,
                                     position: Int,
                                     type: Int) {

        //init
        guard let pipelineState = objectPipelineStates[type] else { return }
        commandEncoder.setComputePipelineState(pipelineState)

        //textures
        commandEncoder.setTexture(DataTask.objectTextures[position], index: 0)

        //buffers
        commandEncoder.setBytes(&DataTask.backgroundValues,
                                length: DataTask.backgroundValues.count * MemoryLayout<Float>.stride,
                                index: 0)

        commandEncoder.setBytes(DataTask.metalValues[position],
                                length: DataTask.metalValues[position].count * MemoryLayout<Float>.stride,
                                index: 1)

        //threads
        let groupsX = (DataTask.objectTextures[position].width + objectThreadsPerGroupX[type] - 1) /
            objectThreadsPerGroupX[type]
        let groupsY = (DataTask.objectTextures[position].height + objectThreadsPerGroupY[type] - 1) /
            objectThreadsPerGroupY[type]

        let threadsPerThreadgroup = MTLSizeMake(objectThreadsPerGroupX[type],
                                                objectThreadsPerGroupY[type],
                                                1)
        let threadgroupsPerGrid = MTLSize(width: groupsX,
                                          height: groupsY,
                                          depth: 1)

        //dispatch
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    private func commandEncodeClean(commandBuffer: MTLCommandBuffer,
                                   commandEncoder: MTLComputeCommandEncoder,
                                   position: Int,
                                   type: Int) {

        //init
        guard let pipelineState = objectPipelineStates[type] else { return }
        commandEncoder.setComputePipelineState(pipelineState)

        //textures
        commandEncoder.setTexture(DataTask.objectTextures[position], index: 0)

        //buffers
        commandEncoder.setBytes(&DataTask.backgroundValues,
                                length: DataTask.backgroundValues.count * MemoryLayout<Float>.stride,
                                index: 0)

        commandEncoder.setBytes(DataTask.metalValues[position],
                                length: DataTask.metalValues[position].count * MemoryLayout<Float>.stride,
                                index: 1)

        //threads
        let groupsX = (DataTask.objectTextures[position].width + objectThreadsPerGroupX[type] - 1) /
            objectThreadsPerGroupX[type]
        let groupsY = (DataTask.objectTextures[position].height + objectThreadsPerGroupY[type] - 1) /
            objectThreadsPerGroupY[type]

        let threadsPerThreadgroup = MTLSizeMake(objectThreadsPerGroupX[type],
                                                objectThreadsPerGroupY[type],
                                                1)
        let threadgroupsPerGrid = MTLSize(width: groupsX,
                                          height: groupsY,
                                          depth: 1)

        //dispatch
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    private func commandEncodeDots(commandBuffer: MTLCommandBuffer,
                                   commandEncoder: MTLComputeCommandEncoder,
                                   position: Int,
                                   type: Int,
                                   dotPosition: Int) {

        //init
        guard let pipelineState = objectPipelineStates[type],
            let dotBuffer = dotBuffer,
            let dotBuffer1 = dotBuffer1 else { return }
        commandEncoder.setComputePipelineState(pipelineState)

        //textures
        commandEncoder.setTexture(DataTask.objectTextures[position], index: 0)

        //buffers
        commandEncoder.setBytes(&DataTask.backgroundValues,
                                length: DataTask.backgroundValues.count * MemoryLayout<Float>.stride,
                                index: 0)

        commandEncoder.setBytes(DataTask.metalValues[position],
                                length: DataTask.metalValues[position].count * MemoryLayout<Float>.stride,
                                index: 1)

        if dotPosition == 0 {
            commandEncoder.setBuffer(dotBuffer, offset: 0, index: 2)
        } else {
            commandEncoder.setBuffer(dotBuffer1, offset: 0, index: 2)
        }

        //threads
        let numberOfDots = DataTask.metalValues[position][MetalValues.imageTextVideoDots].toInt
        let threadsPerThreadgroup = MTLSizeMake(pipelineState.maxTotalThreadsPerThreadgroup, 1, 1)
        let threadgroupsPerGrid = MTLSize(width: numberOfDots / pipelineState.maxTotalThreadsPerThreadgroup + 1,
                                          height: 1,
                                          depth: 1)

        //dispatch
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    private func commandEncodeImage(commandBuffer: MTLCommandBuffer,
                                    commandEncoder: MTLComputeCommandEncoder,
                                    position: Int,
                                    image: MTLTexture,
                                    type: Int) {

        //init
        guard let pipelineState = objectPipelineStates[type] else { return }
        commandEncoder.setComputePipelineState(pipelineState)

        //textures
        commandEncoder.setTexture(DataTask.objectTextures[position], index: 0)
        commandEncoder.setTexture(image, index: 1)

        //buffers
        commandEncoder.setBytes(&DataTask.backgroundValues,
                                length: DataTask.backgroundValues.count * MemoryLayout<Float>.stride,
                                index: 0)

        commandEncoder.setBytes(DataTask.metalValues[position],
                                length: DataTask.metalValues[position].count * MemoryLayout<Float>.stride,
                                index: 1)

        //threads
        let groupsX = (DataTask.objectTextures[position].width + objectThreadsPerGroupX[type] - 1) /
            objectThreadsPerGroupX[type]
        let groupsY = (DataTask.objectTextures[position].height + objectThreadsPerGroupY[type] - 1) /
            objectThreadsPerGroupY[type]

        let threadsPerThreadgroup = MTLSizeMake(objectThreadsPerGroupX[type],
                                                objectThreadsPerGroupY[type],
                                                1)
        let threadgroupsPerGrid = MTLSize(width: groupsX,
                                          height: groupsY,
                                          depth: 1)

        //dispatch
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }

    private func commandEncodeCompute(commandBuffer: MTLCommandBuffer,
                                      commandEncoder: MTLComputeCommandEncoder,
                                      positionsBufferProvider: PositionsBufferProvider,
                                      texture0: MTLTexture) {

        //init
        let computeNumber = Task.shared.computeNumber
        guard let pipelineState = computePipelineStates[computeNumber] else { return }

        commandEncoder.setComputePipelineState(pipelineState)

        //textures
        commandEncoder.setTexture(texture0, index: 0)

        for i in 0 ..< DataTask.objectTextures.count {
            commandEncoder.setTexture(DataTask.objectTextures[i], index: i + 1)
        }

        //buffers
        commandEncoder.setBytes(&DataTask.backgroundValues,
                                length: DataTask.backgroundValues.count * MemoryLayout<Float>.stride,
                                index: 0)

        commandEncoder.setBytes(&DataTask.texturePositions,
                                length: DataTask.texturePositions.count * MemoryLayout<Float>.stride,
                                index: 1)

        let positionsBuffer = positionsBufferProvider.nextPositionsBuffer()

        commandEncoder.setBuffer(positionsBuffer, offset: 0, index: 2)

        //threads
        let threadsPerThreadgroup = MTLSizeMake(Task.shared.computeThreadsPerGroupX[computeNumber],
                                                Task.shared.computeThreadsPerGroupY[computeNumber],
                                                1)
        let threadgroupsPerGrid = MTLSize(width: Task.shared.computeNumberOfGroupsX[computeNumber],
                                          height: Task.shared.computeNumberOfGroupsY[computeNumber],
                                          depth: 1)

        //dispatch
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}
