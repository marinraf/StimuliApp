//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

extension Task {

    struct Point: Hashable {
        let x: Int
        let y: Int
    }

    func firstUpdateSceneTask(_ sceneTask: SceneTask) {
        for trial in 0 ..< sceneTask.numberOfTrials {
            if let updateBackground = sceneTask.updates.first(where: { $0.type == .background }) {
                updateBackground.changeValues(sceneTask: sceneTask, trial: trial, timeInFrames: 0)
            }
            for object in 0 ..< sceneTask.numberOfMetals {
                updatePosition(sceneTask: sceneTask, trial: trial, object: object)
                updateSize(sceneTask: sceneTask, trial: trial, object: object)
                updateBufferPositions(sceneTask: sceneTask, trial: trial, object: object, buffers: false)
            }
        }
    }

    func firstUpdateBuffer() {
        for sectionTask in sectionTasks {
            let trials = sectionTask.numberOfTrials
            for sceneTask in sectionTask.sceneTasks {
                for trial in 0 ..< trials {
                    updateEverything(sceneTask: sceneTask, trialNumber: trial, timeInFrames: 0)
                }
            }
        }
    }

    func updateEverything(sceneTask: SceneTask, trialNumber: Int, timeInFrames: Int) {

        var changePositions: Set<Int> = []
        var changeSizes: Set<Int> = []

        sceneTask.active[trialNumber] = []

        for object in 0 ..< sceneTask.numberOfMetals {
            if sceneTask.activatedBools[trialNumber][object] {
                if timeInFrames >= sceneTask.startTimesInFrames[trialNumber][object] &&
                    timeInFrames < sceneTask.endTimesInFrames[trialNumber][object] {

                    sceneTask.active[trialNumber].append(object)
                }
            }
        }

        //for background object
        if let updateBackground = sceneTask.updates.first(where: { $0.type == .background }) {
            updateBackground.changeValues(sceneTask: sceneTask, trial: trialNumber, timeInFrames: timeInFrames)
        }

        for variable in sceneTask.dependentVariables where
            sceneTask.active[trialNumber].contains(variable.objectNumber) {

                if variable.changingPosition {
                    changePositions.insert(variable.objectNumber)

                } else if variable.changingSize {
                    changeSizes.insert(variable.objectNumber)
                }
        }

        for update in sceneTask.updates where sceneTask.active[trialNumber].contains(update.objectNumber) {

            update.changeValues(sceneTask: sceneTask, trial: trialNumber, timeInFrames: timeInFrames)

            if update.position == MetalValues.xOrigin ||
                update.position == MetalValues.yOrigin ||
                update.position == MetalValues.xPosition ||
                update.position == MetalValues.yPosition {

                changePositions.insert(update.objectNumber)

            } else if update.position == MetalValues.xSize ||
                update.position == MetalValues.ySize ||
                update.position == MetalValues.rotation ||
                update.position == MetalValues.borderDistance ||
                update.position == MetalValues.borderThickness {

                changeSizes.insert(update.objectNumber)
            }
        }

        if let responseMovingObject = responseMovingObject {
            changePositions.remove(responseMovingObject)
        }

        for objectNumber in changePositions {
            updatePosition(sceneTask: sceneTask, trial: trialNumber, object: objectNumber)
        }

        for objectNumber in changeSizes {
            updateSize(sceneTask: sceneTask, trial: trialNumber, object: objectNumber)
        }

        let computeNumber = Task.shared.computeNumber
        let numberOfLayers = Task.shared.numberOfLayers

        DataTask.selectedObjects = Array.init(repeating: 100,
                                              count: computeNumberOfGroups[computeNumber] * numberOfLayers)

        for objectNumber in sceneTask.active[trialNumber] {
            updateBufferPositions(sceneTask: sceneTask, trial: trialNumber, object: objectNumber, buffers: true)
        }
    }

    private func updatePosition(sceneTask: SceneTask, trial: Int, object: Int) {
        sceneTask.xCenter0[trial][object] =
            sceneTask.metalFloats[trial][object][MetalValues.xOrigin] +
            sceneTask.metalFloats[trial][object][MetalValues.xPosition]

        sceneTask.yCenter0[trial][object] =
            sceneTask.metalFloats[trial][object][MetalValues.yOrigin] +
            sceneTask.metalFloats[trial][object][MetalValues.yPosition]
    }

    private func updateSize(sceneTask: SceneTask, trial: Int, object: Int) {
        let distance = sceneTask.metalFloats[trial][object][MetalValues.borderDistance]
        let thickness = sceneTask.metalFloats[trial][object][MetalValues.borderThickness]

        let result = 2 * (distance + thickness)
        let positiveResult = result > 0 ? result : 0

        let shapeType = sceneTask.metalFloats[trial][object][MetalValues.shapeType].toInt
        let xSize = sceneTask.metalFloats[trial][object][MetalValues.xSize] + positiveResult
        let ySize = sceneTask.metalFloats[trial][object][MetalValues.ySize] + positiveResult

        if xSize < 0 || ySize < 0 {
            sceneTask.xSizeMax0[trial][object] = 0
            sceneTask.ySizeMax0[trial][object] = 0
        } else if shapeType == 0 || shapeType == 1 {   //rectangle, ellipse
            let rotation = sceneTask.metalFloats[trial][object][MetalValues.rotation]
            let x = abs(xSize * cos(rotation)) + abs(ySize * sin(rotation))
            let y = abs(xSize * sin(rotation)) + abs(ySize * cos(rotation))
            sceneTask.xSizeMax0[trial][object] = x
            sceneTask.ySizeMax0[trial][object] = y
        } else if shapeType == 3 || shapeType == 4 || shapeType == 5 { //polygon, ring, wedge
            let x = xSize
            sceneTask.xSizeMax0[trial][object] = x
            sceneTask.ySizeMax0[trial][object] = x
        } else if shapeType == 2 { // cross
            let rotation = sceneTask.metalFloats[trial][object][MetalValues.rotation]
            let x = abs(xSize * cos(rotation)) + abs(xSize * sin(rotation))
            sceneTask.xSizeMax0[trial][object] = x
            sceneTask.ySizeMax0[trial][object] = x
        }
    }

    private func updateBufferPositions(sceneTask: SceneTask, trial: Int, object: Int, buffers: Bool) {

        let computeNumber = Task.shared.computeNumber

        //we are in center: (center, center), direction: (right, up)
        let xCenter = sceneTask.xCenter0[trial][object]
        let xSizeMax = sceneTask.xSizeMax0[trial][object]
        let yCenter = sceneTask.yCenter0[trial][object]
        let ySizeMax = sceneTask.ySizeMax0[trial][object]

        var xMin = xCenter - xSizeMax / 2
        var xMax = xCenter + xSizeMax / 2
        var yMin = yCenter - ySizeMax / 2
        var yMax = yCenter + ySizeMax / 2

        let bulgesMinX = max(0, -xMin - semiWidth) //part that bulges from the left
        let bulgesMaxX = max(0, xMax - semiWidth) //part that bulges from the right
        let bulgesMinY = max(0, -yMin - semiHeight) //part that bulges from the bottom
        let bulgesMaxY = max(0, yMax - semiHeight) //part that bulges from the top

        xMin = min(max(xMin - bulgesMinX, -semiWidth), semiWidth)
        xMax = min(max(xMax - bulgesMaxX, -semiWidth), semiWidth)
        yMin = min(max(yMin - bulgesMinY, -semiHeight), semiHeight)
        yMax = min(max(yMax - bulgesMaxY, -semiHeight), semiHeight)

        let realSizeX = xMax - xMin
        let realSizeY = yMax - yMin

        let centerInTextureX = bulgesMaxX / 2 - bulgesMinX / 2
        let centerInTextureY = bulgesMaxY / 2 - bulgesMinY / 2

        sceneTask.xSizeMax[trial][object] = realSizeX
        sceneTask.ySizeMax[trial][object] = realSizeY

        DataTask.objectSizeMax[object] = (realSizeX.toEvenUpInt, realSizeY.toEvenUpInt)
        sceneTask.metalFloats[trial][object][MetalValues.xCenter] = centerInTextureX
        sceneTask.metalFloats[trial][object][MetalValues.yCenter] = centerInTextureY

        guard buffers else { return }

        //transform xMin, xMax, yMin, yMax to center: (left, top), direction: (right, bottom)
        let xMinTexture = xMin + semiWidth
        let xMaxTexture = xMax + semiWidth
        let yMaxTexture = -yMin + semiHeight
        let yMinTexture = -yMax + semiHeight

        //transform pixels to groups
        var xMinTextureGroup = xMinTexture.toInt / computeThreadsPerGroupX[computeNumber]
        var xMaxTextureGroup = xMaxTexture.toInt / computeThreadsPerGroupX[computeNumber]
        var yMinTextureGroup = yMinTexture.toInt / computeThreadsPerGroupY[computeNumber]
        var yMaxTextureGroup = yMaxTexture.toInt / computeThreadsPerGroupY[computeNumber]

        xMinTextureGroup = min(max(xMinTextureGroup, 0), computeNumberOfGroupsX[computeNumber] - 1)
        xMaxTextureGroup = min(max(xMaxTextureGroup, 0), computeNumberOfGroupsX[computeNumber] - 1)
        yMinTextureGroup = min(max(yMinTextureGroup, 0), computeNumberOfGroupsY[computeNumber] - 1)
        yMaxTextureGroup = min(max(yMaxTextureGroup, 0), computeNumberOfGroupsY[computeNumber] - 1)

        DataTask.texturePositions[object] = xMinTexture
        DataTask.texturePositions[object + Constants.maxNumberOfMetalStimuli] = yMinTexture

        let numberOfLayers = Task.shared.numberOfLayers
        for x in xMinTextureGroup ... xMaxTextureGroup {
            for y in yMinTextureGroup ... yMaxTextureGroup {
                var loop = true
                for layer in 0 ..< numberOfLayers where loop {
                    let position = (y * computeNumberOfGroupsX[computeNumber] + x) * numberOfLayers + layer
                    if DataTask.selectedObjects[position] == 100 {
                        DataTask.selectedObjects[position] = Float(object)
                        loop = false
                    }
                }
            }
        }
    }
}
