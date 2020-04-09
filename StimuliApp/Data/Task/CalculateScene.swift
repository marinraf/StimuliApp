//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import GameKit

struct DataToPass {

    let trials: Int
    let position: Int
    let object: Object
    let objectNumber: Int
    let type: TypeData
}

extension Task {

    // MARK: - Calculate scene
    func calculateScene(from scene: Scene) -> String {

        sceneTask = SceneTask()
        sceneTask.name = scene.name.string
        sceneTask.id = scene.id
        sceneTask.numberOfTrials = sectionTask.numberOfTrials
        sceneTask.numberOfLayers = scene.numberOfLayers.selectedValue + 1
        sceneTask.continuousResolution = scene.continuousResolution.selectedValue == 0 ? false : true
        createDots()
        for _ in 0 ..< sceneTask.numberOfTrials {
            sceneTask.seeds.append(Seed(id: ""))
            sceneTask.checkPoints.append([])
        }

        sceneTask.metalFloats = Array(repeating: [], count: sceneTask.numberOfTrials)
        let sineWaveArray: [Float] = Array(repeating: 0, count: Constants.numberOfSineWaveFloats)
        sceneTask.sineWaveFloats = Array(repeating: sineWaveArray, count: sceneTask.numberOfTrials)

        var dots = 0
        var videos = 0
        var texts = 0
        var audios = 0
        var tones = 0
        var metals = 0

        for _ in 0 ..< sceneTask.numberOfTrials {
            sceneTask.backgroundFloats.append([])
            sceneTask.activatedBools.append([])
            sceneTask.startTimesInFrames.append([])
            sceneTask.durationTimesInFrames.append([])
            sceneTask.endTimesInFrames.append([])
            sceneTask.xSizeMax.append([])
            sceneTask.ySizeMax.append([])
            sceneTask.xSizeMax0.append([])
            sceneTask.ySizeMax0.append([])
            sceneTask.xCenter0.append([])
            sceneTask.yCenter0.append([])
            sceneTask.active.append([])
            sceneTask.images.append([])
            sceneTask.textObjects.append([])
            sceneTask.videoObjects.append([])
            sceneTask.audioObjects.append([])
            sceneTask.sineWaveObjects.append([])
        }

        for (index, object) in scene.objects.enumerated() {
            if index == 0 {
                // do nothing
            } else if object.type == .image {
                createMetal(from: object, objectNumber: metals)
                let result = createImage(from: object, objectNumber: metals)
                if result != "" {
                    return result
                }
                metals += 1
            } else if object.type == .dots {
                createMetal(from: object, objectNumber: metals)
                let numberOfDots = checkNumberOfDots(objectNumber: metals)
                if numberOfDots != "" {
                    return numberOfDots
                }
                metals += 1
                dots += 1
                if dots > Constants.maxNumberOfDotObjects {
                    return """
                    ERROR: the maximum number of dot objects is: \(Constants.maxNumberOfDotObjects).
                    """
                }
            } else if object.type == .video {
                let result = createVideo(from: object, objectNumber: videos)
                if result != "" {
                    return result
                }
                videos += 1
                if videos > Constants.maxNumberOfVideoObjects {
                    return """
                    ERROR: the maximum number of video objects is: \(Constants.maxNumberOfVideoObjects).
                    """
                }
            } else if object.type == .text {
                let result = createText(from: object, objectNumber: texts)
                if result != "" {
                    return result
                }
                texts += 1
            } else if object.type == .audio {
                let result = createAudio(from: object, objectNumber: audios)
                if result != "" {
                    return result
                }
                audios += 1
            } else if object.type == .pureTone {
                createPureTone(from: object, objectNumber: tones)
                tones += 1
                if tones > Constants.maxNumberOfSineWaveObjects {
                    return """
                    ERROR: the maximum number of video objects is: \(Constants.maxNumberOfSineWaveObjects).
                    """
                }
            } else {
                createMetal(from: object, objectNumber: metals)
                metals += 1
            }
        }
        sceneTask.numberOfMetals = metals

        guard sceneTask.numberOfMetals <= Constants.maxNumberOfMetalStimuli else {
            return """
            ERROR: there are \(sceneTask.numberOfMetals) visual stimuli in the scene: \(sceneTask.name).
            The maximum number of visual stimuli allowed in a scene is: \(Constants.maxNumberOfMetalStimuli).
            """
        }

        createBackground(from: scene)
        createFinalCheckPoints(from: scene)
        createSineWaveFloats()
        createResponse(from: scene)

        firstUpdateSceneTask(sceneTask)

        sectionTask.sceneTasks.append(sceneTask)

        return ""
    }

    private func createDots() {
        let max = Constants.maxNumberOfDots * Constants.numberOfDotsFloats

        Task.shared.dots = Array(repeating: 0, count: max)
        Task.shared.dots1 = Array(repeating: 0, count: max)

        for j in 0 ..< max {
            Task.shared.dots[j] = Float.random(in: 0 ... 1)
            Task.shared.dots1[j] = Float.random(in: 0 ... 1)
        }
    }

    private func createMetal(from object: Object, objectNumber: Int) {
        guard let stimulus = object.stimulus else { return }

        let trials = sceneTask.numberOfTrials
        let zeroArray: [Float] = Array(repeating: 0, count: trials)
        var index = 0
        let frameRate = Float(Flow.shared.settings.frameRate)

        // activated
        let activatedFloats = getValues(from: stimulus.activatedProperty,
                                        object: object,
                                        position: 0,
                                        objectNumber: objectNumber,
                                        type: .activatedBools)[0]

        let activated = activatedFloats.map({ $0 > 0.5 ? true : false })

        // start, duration, end
        let startFloats = getValues(from: stimulus.startProperty,
                                        object: object,
                                        position: 0,
                                        objectNumber: objectNumber,
                                        type: .start)[0]
        let start = startFloats.map({ ($0 * frameRate).toInt })

        let durationFloats = getValues(from: stimulus.durationProperty,
                                        object: object,
                                        position: 0,
                                        objectNumber: objectNumber,
                                        type: .duration)[0]
        let duration = durationFloats.map({ ($0 * frameRate).toInt })

        let end = zip(start, duration).map(+)

        // type and type properties
        let typeValues = Array(repeating: Float(stimulus.typeProperty.selectedValue), count: trials) //0
        var typePropValues = Array(repeating: zeroArray, count: 20) //1...20
        index = 0
        for property in stimulus.typeProperty.properties {
            if property.propertyType == .image {
                typePropValues[index] = Array(repeating: 0, count: trials)
                index += 1
            } else if property.propertyType == .behaviour {
                typePropValues[index] = Array(repeating: Float(property.selectedValue), count: trials)
                index += 1
            } else if property.propertyType == .direction {
                typePropValues[index] = Array(repeating: Float(property.selectedValue), count: trials)
                index += 1
                let values = getValues(from: property.properties[0],
                                       object: object,
                                       position: index + 1,
                                       objectNumber: objectNumber,
                                       type: .metal)

                for item in values {
                    typePropValues[index] = item
                    index += 1
                }
                if property.properties.count == 2 {
                    let values1 = getValues(from: property.properties[1],
                                            object: object,
                                            position: index + 1,
                                            objectNumber: objectNumber,
                                            type: .metal)
                    for item in values1 {
                        typePropValues[index] = item
                        index += 1
                    }
                } else {
                    typePropValues[index] = Array(repeating: 0, count: trials)
                    index += 1
                }
            } else {
                let values = getValues(from: property,
                                       object: object,
                                       position: index + 1,
                                       objectNumber: objectNumber,
                                       type: .metal)
                for item in values {
                    typePropValues[index] = item
                    index += 1
                }
            }
        }

        // shape and shape properties
        let shapeValues = Array(repeating: Float(stimulus.shapeProperty.selectedValue), count: trials) //21
        var shapePropValues = Array(repeating: zeroArray, count: 2) //22...23
        index = 0
        for property in stimulus.shapeProperty.properties {
            let values = getValues(from: property,
                                   object: object,
                                   position: 22 + index,
                                   objectNumber: objectNumber,
                                   type: .metal)
            for item in values {
                shapePropValues[index] = item
                index += 1
            }
        }

        // duration properties
        let startValues = getValues(from: stimulus.startProperty,
                                    object: object,
                                    position: 24,
                                    objectNumber: objectNumber,
                                    type: .metal)[0]

        let durationValues = getValues(from: stimulus.durationProperty,
                                       object: object,
                                       position: 25,
                                       objectNumber: objectNumber,
                                       type: .metal)[0]

        //position properties
        let originValues = getValues(from: stimulus.originProperty,
                                     object: object,
                                     position: 26,
                                     objectNumber: objectNumber,
                                     type: .metal)

        let positionValues = getValues(from: stimulus.positionProperty,
                                       object: object,
                                       position: 28,
                                       objectNumber: objectNumber,
                                       type: .metal)

        let rotationValues = getValues(from: stimulus.rotationProperty,
                                       object: object,
                                       position: 32,
                                       objectNumber: objectNumber,
                                       type: .metal)[0]

        //border properties
        let borderValues = Array(repeating: Float(stimulus.borderProperty.selectedValue), count: trials) //33
        var borderPropValues = Array(repeating: zeroArray, count: 5) //34...38
        index = 0
        for property in stimulus.borderProperty.properties {
            let values = getValues(from: property,
                                   object: object,
                                   position: 34 + index,
                                   objectNumber: objectNumber,
                                   type: .metal)
            for item in values {
                borderPropValues[index] = item
                index += 1
            }
        }

        //contrast properties
        let contrastValues = Array(repeating: Float(stimulus.contrastProperty.selectedValue), count: trials) //39
        var contrastPropValues = Array(repeating: zeroArray, count: 2) //40...41
        index = 0
        for property in stimulus.contrastProperty.properties {
            let values = getValues(from: property,
                                   object: object,
                                   position: 40 + index,
                                   objectNumber: objectNumber,
                                   type: .metal)
            for item in values {
                contrastPropValues[index] = item
                index += 1
            }
        }

        //noise properties
        let noiseValues = Array(repeating: Float(stimulus.noiseProperty.selectedValue), count: trials) //42
        var noisePropValues = Array(repeating: zeroArray, count: 7) //43...49
        index = 0
        for property in stimulus.noiseProperty.properties {
            let values = getValues(from: property,
                                   object: object,
                                   position: 43 + index,
                                   objectNumber: objectNumber,
                                   type: .metal)
            for item in values {
                noisePropValues[index] = item
                index += 1
            }
        }

        //modulator properties
        let modulatorValues = Array(repeating: Float(stimulus.modulatorProperty.selectedValue), count: trials) //50
        var modulatorPropValues = Array(repeating: zeroArray, count: 4) //51...54
        index = 0
        for property in stimulus.modulatorProperty.properties {
            let values = getValues(from: property,
                                   object: object,
                                   position: 51 + index,
                                   objectNumber: objectNumber,
                                   type: .metal)
            for item in values {
                modulatorPropValues[index] = item
                index += 1
            }
        }

        for i in 0 ..< trials {
            sceneTask.metalFloats[i].append([])

            sceneTask.metalFloats[i][objectNumber].append(typeValues[i])
            for j in 0 ..< 20 {
                sceneTask.metalFloats[i][objectNumber].append(typePropValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(shapeValues[i])
            for j in 0 ..< 2 {
                sceneTask.metalFloats[i][objectNumber].append(shapePropValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(startValues[i])
            sceneTask.metalFloats[i][objectNumber].append(durationValues[i])
            for j in 0 ..< 2 {
                sceneTask.metalFloats[i][objectNumber].append(originValues[j][i])
            }
            for j in 0 ..< 2 {
                sceneTask.metalFloats[i][objectNumber].append(positionValues[j][i])
            }
            for j in 0 ..< 2 {
                sceneTask.metalFloats[i][objectNumber].append(originValues[j][i] + positionValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(rotationValues[i])
            sceneTask.metalFloats[i][objectNumber].append(borderValues[i])
            for j in 0 ..< 5 {
                sceneTask.metalFloats[i][objectNumber].append(borderPropValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(contrastValues[i])
            for j in 0 ..< 2 {
                sceneTask.metalFloats[i][objectNumber].append(contrastPropValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(noiseValues[i])
            for j in 0 ..< 7 {
                sceneTask.metalFloats[i][objectNumber].append(noisePropValues[j][i])
            }
            sceneTask.metalFloats[i][objectNumber].append(modulatorValues[i])
            for j in 0 ..< 4 {
                sceneTask.metalFloats[i][objectNumber].append(modulatorPropValues[j][i])
            }

            sceneTask.activatedBools[i].append(activated[i])
            sceneTask.startTimesInFrames[i].append(start[i])
            sceneTask.durationTimesInFrames[i].append(duration[i])
            sceneTask.endTimesInFrames[i].append(end[i])
            sceneTask.xSizeMax[i].append(0)
            sceneTask.ySizeMax[i].append(0)
            sceneTask.xSizeMax0[i].append(0)
            sceneTask.ySizeMax0[i].append(0)
            sceneTask.xCenter0[i].append(0)
            sceneTask.yCenter0[i].append(0)
            sceneTask.images[i].append(-1)
        }
    }

    private func createBackground(from scene: Scene) {

        let trials = sceneTask.numberOfTrials

        let backgroundValues = getValues(from: scene.color,
                                         object: scene.objects[0],
                                         position: 1,
                                         objectNumber: 1,
                                         type: .background)

        let moreColors: Float = scene.continuousResolution.selectedValue == 0 ? 0 : 1

        for i in 0 ..< trials {
            let randomValue = Float.random(in: 0 ... 10000)
            sceneTask.backgroundFloats[i].append(inversGamma) //0 = inversGamma
            sceneTask.backgroundFloats[i].append(backgroundValues[0][i]) //1 = colorRed
            sceneTask.backgroundFloats[i].append(backgroundValues[1][i]) //2 = colorGreen
            sceneTask.backgroundFloats[i].append(backgroundValues[2][i]) //3 = colorBlue
            sceneTask.backgroundFloats[i].append(0) //4 = timeInFrames
            sceneTask.backgroundFloats[i].append(Float(Flow.shared.settings.frameRate)) //5 = frameRate
            sceneTask.backgroundFloats[i].append(randomValue) // 6 = randomSeed
            sceneTask.backgroundFloats[i].append(randomValue) // 7 = randomSeedInitial
            sceneTask.backgroundFloats[i].append(0) // 8 = screenWidth
            sceneTask.backgroundFloats[i].append(0) // 9 = screenHeight
            sceneTask.backgroundFloats[i].append(gamma) //10 = gamma
            sceneTask.backgroundFloats[i].append(moreColors) //11 = moreColors
            sceneTask.backgroundFloats[i].append(1) //12 = status (0==stop, 1==play, 2==plus, 3==reverse)
        }
    }

    private func createFinalCheckPoints(from scene: Scene) {

        sceneTask.durationType = FixedDuration(rawValue: scene.durationType.string) ?? .constant
        var time: Int = 0
        if sceneTask.durationType == .constant {
            time = (scene.durationType.properties[0].float * Float(Flow.shared.settings.frameRate)).toInt
        }
        let checkPoint = SceneTask.CheckPoint(time: time, action: .endScene, objectNumber: 0, type: .endScene)

        for trial in 0 ..< sceneTask.numberOfTrials {
            sceneTask.checkPoints[trial].append(checkPoint)
            modifyFinalCheckPoint(trial: trial)
            sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].sorted(by: { $0.time < $1.time })
        }
    }

    func modifyFinalCheckPoint(trial: Int) {
        guard sceneTask.durationType == .stimuli else { return }

        sceneTask.checkPoints[trial] = sceneTask.checkPoints[trial].filter({ $0.action != .endScene })

        var time: Int = 0
        for i in 0 ..< sceneTask.endTimesInFrames[trial].count {
            if sceneTask.activatedBools[trial][i] {
                time = max(time, sceneTask.endTimesInFrames[trial][i])
            }
        }
        for checkPoint in sceneTask.checkPoints[trial] {
            time = max(time, checkPoint.time)
        }
        let checkPoint = SceneTask.CheckPoint(time: time, action: .endScene, objectNumber: 0, type: .endScene)
        sceneTask.checkPoints[trial].append(checkPoint)
    }

    private func createImage(from object: Object, objectNumber: Int) -> String {
        guard let listOfImages = Flow.shared.test.listsOfValues.first(where: { $0.type == .images }) else {
            return """
            ERROR: there is not a list of images. Go to the "list" menu to create a list containing all \
            the images you want to draw.
            """
        }

        guard let stimulus = object.stimulus else { return "" }

        let trials = sceneTask.numberOfTrials

        //image
        let imageFloats = getValues(from: stimulus.typeProperty.properties[0],
                                    object: object,
                                    position: 0,
                                    objectNumber: objectNumber,
                                    type: .image)[0]
        let imageInts = imageFloats.map({ $0.toInt - 1 })
        if let imageNumber = imageInts.first(where: { $0 > listOfImages.goodValues.count }) {
            return """
            ERROR: the image number: \(imageNumber + 1) does not exist in the list of images.
            """
        }
        let imageNames = imageInts.map({ listOfImages.goodValues[$0].somethingId })
        let allImageNames = listOfImages.goodValues.map({ $0.somethingId })

        for name in allImageNames {
            var image: UIImage?

            if images.first(where: { $0.name == name }) != nil {
                    //do nothing
            } else {
                image = FilesAndPermission.getImage(imageName: name)
                images.append((name, image))
            }
        }

        for i in 0 ..< trials {
            sceneTask.images[i][objectNumber] = images.count - 1

            if let image = images.first(where: { $0.name == imageNames[i] }),
                let index = images.firstIndex(where: { $0.name == image.name }) {

                sceneTask.images[i][objectNumber] = index
            }
        }
        return ""
    }

    private func createText(from object: Object, objectNumber: Int) -> String {
        guard let listOfTexts = Flow.shared.test.listsOfValues.first(where: { $0.dimensions == 5 }) else {
            return  """
            ERROR: there is not a list of texts. Go to the "list" menu to create a list containing all \
            the texts you want to draw.
            """
        }
        guard let stimulus = object.stimulus else { return "" }

        let frameRate = Float(Flow.shared.settings.frameRate)

        let trials = sceneTask.numberOfTrials

        //activated
        let activatedFloats = getValues(from: stimulus.activatedProperty,
                                        object: object,
                                        position: 10,
                                        objectNumber: objectNumber,
                                        type: .text)[0]
        let activated = activatedFloats.map({ $0 > 0.5 ? true : false })

        // start, duration, end
        let startFloats = getValues(from: stimulus.startProperty,
                                    object: object,
                                    position: 11,
                                    objectNumber: objectNumber,
                                    type: .text)[0]
        let start = startFloats.map({ ($0 * frameRate).toInt })

        let durationFloats = getValues(from: stimulus.durationProperty,
                                       object: object,
                                       position: 12,
                                       objectNumber: objectNumber,
                                       type: .text)[0]
        let duration = durationFloats.map({ ($0 * frameRate).toInt })

        let end = zip(start, duration).map(+)

        //text
        let textFloats = getValues(from: stimulus.typeProperty.properties[0],
                                   object: object,
                                   position: 0,
                                   objectNumber: objectNumber,
                                   type: .text)[0]
        let textInts = textFloats.map({ $0.toInt - 1 })
        if let textNumber = textInts.first(where: { $0 > listOfTexts.goodValues.count }) {
            return """
            ERROR: the text number: \(textNumber + 1) does not exist in the list of texts.
            """
        }
        let texts = textInts.map({ listOfTexts.goodValues[$0].text })

        //font
        let fontName = stimulus.typeProperty.properties[1].string

        //textSize
        let sizeFloats = getValues(from: stimulus.typeProperty.properties[2],
                                   object: object,
                                   position: 2,
                                   objectNumber: objectNumber,
                                   type: .text)[0]
        var fonts: [UIFont] = []
        for size in sizeFloats {
            fonts.append(UIFont(name: fontName, size: CGFloat(size)) ?? UIFont.systemFont(ofSize: CGFloat(size)))
        }

        //positionX
        let positionsX = getValues(from: stimulus.typeProperty.properties[3],
                                   object: object,
                                   position: 3,
                                   objectNumber: objectNumber,
                                   type: .text)[0]

        //positionY
        let positionsY = getValues(from: stimulus.typeProperty.properties[4],
                                   object: object,
                                   position: 4,
                                   objectNumber: objectNumber,
                                   type: .text)[0]

        //color
        let colorFloats = getValues(from: stimulus.typeProperty.properties[5],
                                    object: object,
                                    position: 5,
                                    objectNumber: objectNumber,
                                    type: .text)

        let reds = colorFloats[0]
        let greens = colorFloats[1]
        let blues = colorFloats[2]

        let tag = objectNumber + Constants.textViewTag

        for i in 0 ..< trials {
            let textObject = TextObject(activated: activated[i],
                                        start: start[i],
                                        end: end[i],
                                        tag: tag,
                                        text: texts[i],
                                        font: fonts[i],
                                        positionX: CGFloat(positionsX[i]),
                                        positionY: CGFloat(positionsY[i]),
                                        red: CGFloat(reds[i]),
                                        green: CGFloat(greens[i]),
                                        blue: CGFloat(blues[i]))

            sceneTask.textObjects[i].append(textObject)

            let checkPoint = SceneTask.CheckPoint(time: start[i], action: .startText,
                                                  objectNumber: objectNumber, type: .text)
            let checkPoint2 = SceneTask.CheckPoint(time: end[i], action: .endText,
                                                   objectNumber: objectNumber, type: .text)

            if activated[i] {
                sceneTask.checkPoints[i] += [checkPoint, checkPoint2]
            }

        }
        return ""
    }

    private func createVideo(from object: Object, objectNumber: Int) -> String {

        guard let listOfVideos = Flow.shared.test.listsOfValues.first(where: { $0.type == .videos }) else {
            return  """
            ERROR: there is not a list of videos. Go to the "list" menu to create a list containing all \
            the videos you want to play.
            """
        }
        guard let stimulus = object.stimulus else { return "" }

        let frameRate = Float(Flow.shared.settings.frameRate)

        let trials = sceneTask.numberOfTrials

        //activated
        let activatedFloats = getValues(from: stimulus.activatedProperty,
                                        object: object,
                                        position: 10,
                                        objectNumber: objectNumber,
                                        type: .video)[0]

        let activated = activatedFloats.map({ $0 > 0.5 ? true : false })

        // start, duration, end
        let startFloats = getValues(from: stimulus.startProperty,
                                    object: object,
                                    position: 11,
                                    objectNumber: objectNumber,
                                    type: .video)[0]
        let start = startFloats.map({ ($0 * frameRate).toInt })

        let durationFloats = getValues(from: stimulus.durationProperty,
                                       object: object,
                                       position: 12,
                                       objectNumber: objectNumber,
                                       type: .video)[0]
        let duration = durationFloats.map({ ($0 * frameRate).toInt })

        let end = zip(start, duration).map(+)

        //video
        let videoFloats = getValues(from: stimulus.typeProperty.properties[0],
                                    object: object,
                                    position: 0,
                                    objectNumber: objectNumber,
                                    type: .video)[0]
        let videoInts = videoFloats.map({ $0.toInt - 1 })
        if let videoNumber = videoInts.first(where: { $0 > listOfVideos.goodValues.count }) {
            return """
            ERROR: the video number: \(videoNumber + 1) does not exist in the list of videos.
            """
        }
        let videoNames = videoInts.map({ listOfVideos.goodValues[$0].somethingId })
        let allVideoNames = listOfVideos.goodValues.map({ $0.somethingId })

        for name in allVideoNames {
            var video: (name: String, url: URL?)

            if videos.first(where: { $0.name == name }) != nil {
                //do nothing
            } else {
                let url = FilesAndPermission.getVideo(videoName: name)
                video = (name, url)
                videos.append(video)
            }
        }

        let tag = objectNumber + Constants.videoViewTag

        for i in 0 ..< trials {

            let video = videos.first(where: { $0.name == videoNames[i] })

            let videoObject = VideoObject(activated: activated[i],
                                          start: start[i],
                                          end: end[i],
                                          tag: tag,
                                          url: video?.url)

            sceneTask.videoObjects[i].append(videoObject)

            let checkPoint = SceneTask.CheckPoint(time: start[i], action: .startVideo,
                                                  objectNumber: objectNumber, type: .video)
            let checkPoint2 = SceneTask.CheckPoint(time: end[i], action: .endVideo,
                                                   objectNumber: objectNumber, type: .video)

            if activated[i] {
                sceneTask.checkPoints[i] += [checkPoint, checkPoint2]
            }
        }
        return ""
    }

    private func createAudio(from object: Object, objectNumber: Int) -> String {

        guard let listOfAudios = Flow.shared.test.listsOfValues.first(where: { $0.type == .audios }) else {
            return  """
            ERROR: there is not a list of audios. Go to the "list" menu to create a list containing all \
            the audios you want to play.
            """
        }
        guard let stimulus = object.stimulus else { return "" }

        let frameRate = Float(Flow.shared.settings.frameRate)

        let trials = sceneTask.numberOfTrials

        //activated
        let activatedFloats = getValues(from: stimulus.activatedProperty,
                                        object: object,
                                        position: 10,
                                        objectNumber: objectNumber,
                                        type: .audio)[0]

        let activated = activatedFloats.map({ $0 > 0.5 ? true : false })

        // start, duration, end
        let startFloats = getValues(from: stimulus.startProperty,
                                    object: object,
                                    position: 11,
                                    objectNumber: objectNumber,
                                    type: .audio)[0]
        let start = startFloats.map({ ($0 * frameRate).toInt })

        let durationFloats = getValues(from: stimulus.durationProperty,
                                       object: object,
                                       position: 12,
                                       objectNumber: objectNumber,
                                       type: .audio)[0]
        let duration = durationFloats.map({ ($0 * frameRate).toInt })

        let end = zip(start, duration).map(+)

        //audio
        let audioFloats = getValues(from: stimulus.typeProperty.properties[0],
                                    object: object,
                                    position: 0,
                                    objectNumber: objectNumber,
                                    type: .audio)[0]
        let audioInts = audioFloats.map({ $0.toInt - 1 })
        if let audioNumber = audioInts.first(where: { $0 > listOfAudios.goodValues.count }) {
            return """
            ERROR: the audio number: \(audioNumber + 1) does not exist in the list of audios.
            """
        }
        let audioNames = audioInts.map({ listOfAudios.goodValues[$0].somethingId })
        let allAudioNames = listOfAudios.goodValues.map({ $0.somethingId })

        for name in allAudioNames {
            var audio: (name: String, url: URL?)

            if audios.first(where: { $0.name == name }) != nil {
                //do nothing
            } else {
                let url = FilesAndPermission.getAudio(audioName: name)
                audio = (name, url)
                audios.append(audio)
            }
        }

        for i in 0 ..< trials {
            let audio = audios.first(where: { $0.name == audioNames[i] })

            let audioObject = AudioObject(activated: activated[i],
                                          start: start[i],
                                          end: end[i],
                                          url: audio?.url)

            sceneTask.audioObjects[i].append(audioObject)

            let checkPoint = SceneTask.CheckPoint(time: start[i], action: .startAudio,
                                                  objectNumber: objectNumber, type: .audio)
            let checkPoint2 = SceneTask.CheckPoint(time: end[i], action: .endAudio,
                                                   objectNumber: objectNumber, type: .audio)

            if activated[i] {
                sceneTask.checkPoints[i] += [checkPoint, checkPoint2]
            }
        }
        return ""
    }

    private func createPureTone(from object: Object, objectNumber: Int) {

        guard let stimulus = object.stimulus else { return }

        let frameRate = Float(Flow.shared.settings.frameRate)

        let trials = sceneTask.numberOfTrials

        //activated
        let activatedFloats = getValues(from: stimulus.activatedProperty,
                                        object: object,
                                        position: 10,
                                        objectNumber: objectNumber,
                                        type: .pureTone)[0]

        let activated = activatedFloats.map({ $0 > 0.5 ? true : false })

        // start, duration, end
        let startFloats = getValues(from: stimulus.startProperty,
                                    object: object,
                                    position: 11,
                                    objectNumber: objectNumber,
                                    type: .pureTone)[0]
        let start = startFloats.map({ ($0 * frameRate).toInt })

        let durationFloats = getValues(from: stimulus.durationProperty,
                                       object: object,
                                       position: 12,
                                       objectNumber: objectNumber,
                                       type: .pureTone)[0]
        let duration = durationFloats.map({ ($0 * frameRate).toInt })

        let endFloats = zip(startFloats, durationFloats).map(+)
        let end = zip(start, duration).map(+)

        //frequency
        let soundType = FixedSoundType(rawValue: stimulus.typeProperty.properties[0].string) ?? .none

        var frequencies: [Float] = Array(repeating: 0, count: trials)

        switch soundType {
        case .pureTone:
            frequencies = getValues(from: stimulus.typeProperty.properties[0].properties[0],
                                        object: object,
                                        position: 1,
                                        objectNumber: objectNumber,
                                        type: .pureTone)[0]
        default:
            break
        }

        //amplitude
        let amplitudes = getValues(from: stimulus.typeProperty.properties[1],
                                   object: object,
                                   position: 1,
                                   objectNumber: objectNumber,
                                   type: .pureTone)[0]

        //channel
        let channels = getValues(from: stimulus.typeProperty.properties[2],
                                    object: object,
                                    position: 2,
                                    objectNumber: objectNumber,
                                    type: .pureTone)[0]

        var dependCorrection = false
        if sceneTask.dependentVariables.first(where: { $0.variableTask.object === object}) != nil {
            dependCorrection = true
        }

        for i in 0 ..< trials {
            let amplitude = amplitudes[i]
            let frequency = frequencies[i]
            let channel = channels[i]

            let sineWaveObject = SineWaveObject(activated: activated[i],
                                                dependCorrection: dependCorrection,
                                                start: start[i],
                                                end: end[i],
                                                startFloat: startFloats[i],
                                                endFloat: endFloats[i],
                                                amplitude: amplitude,
                                                frequency: frequency,
                                                channel: channel)

            sceneTask.sineWaveObjects[i].append(sineWaveObject)

            let checkPoint = SceneTask.CheckPoint(time: start[i], action: .startSineWave,
                                                  objectNumber: objectNumber, type: .sineWave)
            let checkPoint2 = SceneTask.CheckPoint(time: end[i], action: .endSineWave,
                                                   objectNumber: objectNumber, type: .sineWave)

            if activated[i] {
                sceneTask.checkPoints[i] += [checkPoint, checkPoint2]
            }
        }
    }

    private func createSineWaveFloats() {

        let trials = sectionTask.numberOfTrials
        let rampTime = Flow.shared.settings.rampTime
        let audioRate = Float(Flow.shared.settings.audioRate)

        for i in 0 ..< trials {
            let sineWaveObjectNumber = sceneTask.sineWaveObjects[i].count
            sceneTask.sineWaveFloats[i][0] = rampTime * audioRate
            sceneTask.sineWaveFloats[i][1] = Float(sineWaveObjectNumber)

            for j in 0 ..< sineWaveObjectNumber {

                sceneTask.sineWaveFloats[i][j + 3] = sceneTask.sineWaveObjects[i][j].startFloat * audioRate
                sceneTask.sineWaveFloats[i][j + 13] = 0
                sceneTask.sineWaveFloats[i][j + 23] = sceneTask.sineWaveObjects[i][j].frequency
                sceneTask.sineWaveFloats[i][j + 33] = sceneTask.sineWaveObjects[i][j].amplitude
                sceneTask.sineWaveFloats[i][j + 43] = sceneTask.sineWaveObjects[i][j].channel
                if sceneTask.sineWaveObjects[i][j].activated || sceneTask.sineWaveObjects[i][j].dependCorrection {
                    sceneTask.sineWaveFloats[i][j + 13] = sceneTask.sineWaveObjects[i][j].endFloat * audioRate
                }
            }

            sceneTask.sineWaveFloats[i][2] = sceneTask.sineWaveFloats[i][13 ..< 23].max() ?? 0

            for j in 3 ..< 23 {
                sceneTask.sineWaveFloats[i][j] = sceneTask.sineWaveFloats[i][2] - sceneTask.sineWaveFloats[i][j]
            }
        }
    }

    func modifySineWaveFloats(trial: Int, object: Int) {
        let audioRate = Float(Flow.shared.settings.audioRate)

        sceneTask.sineWaveFloats[trial][object + 3] = sceneTask.sineWaveObjects[trial][object].startFloat * audioRate
        sceneTask.sineWaveFloats[trial][object + 13] = 0
        sceneTask.sineWaveFloats[trial][object + 23] = sceneTask.sineWaveObjects[trial][object].frequency
        sceneTask.sineWaveFloats[trial][object + 33] = sceneTask.sineWaveObjects[trial][object].amplitude
        sceneTask.sineWaveFloats[trial][object + 43] = sceneTask.sineWaveObjects[trial][object].channel
        if sceneTask.sineWaveObjects[trial][object].activated {
            sceneTask.sineWaveFloats[trial][object + 13] = sceneTask.sineWaveObjects[trial][object].endFloat * audioRate
        }

        let oldDuration = sceneTask.sineWaveFloats[trial][2]

        for j in 0 ..< 10 where j != object {
            sceneTask.sineWaveFloats[trial][j + 3] = oldDuration - sceneTask.sineWaveFloats[trial][j + 3]
            sceneTask.sineWaveFloats[trial][j + 13] = oldDuration - sceneTask.sineWaveFloats[trial][j + 13]
        }

        sceneTask.sineWaveFloats[trial][2] = sceneTask.sineWaveFloats[trial][13 ..< 23].max() ?? 0

        for j in 3 ..< 23 {
            sceneTask.sineWaveFloats[trial][j] = sceneTask.sineWaveFloats[trial][2] - sceneTask.sineWaveFloats[trial][j]
        }
    }

    func createResponse(from scene: Scene) {

        sceneTask.responseKeys = []
        let frameRate = Float(Flow.shared.settings.frameRate)

        let responseType = FixedResponse(rawValue: scene.responseType.string) ?? .none
        sceneTask.responseType = responseType

        switch responseType {
        case .none:
            break
        case .keyboard:
            sceneTask.responseKeyboard = FixedKeyboard(rawValue: scene.responseType.properties[0].string) ?? .normal
            sceneTask.responseInTitle = FixedResponseInTitle(rawValue: scene.responseType.properties[1].string) == .yes
        case .keys:
            sceneTask.responseKeys = Array.init(repeating: ("", ""), count: 10)
            var i = 0
            for property in scene.responseType.properties where property.selectedValue != 0 {
                var key = ""
                var value = ""
                if property.string == "other key" {
                    key = property.properties[0].string
                    value = String(property.properties[1].float)
                } else {
                    key = FixedKeyResponse(rawValue: property.string)?.value ?? ""
                    value = String(property.properties[0].float)
                }
                sceneTask.responseKeys[i] = (key, value)
                i += 1
            }
        case .leftRight, .topBottom:
            sceneTask.responseStartInFrames = (scene.responseType.properties[0].float * frameRate).toInt
            sceneTask.responseObject = [scene.responseType.properties[1].float, scene.responseType.properties[2].float]
        case .touch, .path:
            sceneTask.responseStartInFrames = (scene.responseType.properties[0].float * frameRate).toInt
            sceneTask.responseOrigin = getOrigin2dValue(from: scene.responseType.properties[1])
            sceneTask.responseCoordinates = FixedPositionResponse(rawValue: scene.responseType.properties[2].string) ??
                .cartesian
            sceneTask.responseFirstUnit = Unit(rawValue: scene.responseType.properties[2].properties[0].string) ??
                .none
            sceneTask.responseSecondUnit = Unit(rawValue: scene.responseType.properties[2].properties[1].string) ??
                .none
        case .touchObject:
            sceneTask.responseStartInFrames = (scene.responseType.properties[0].float * frameRate).toInt
            let backgroundInteractive = FixedObjectResponse(rawValue: scene.responseType.properties[1].string) ?? .no
            if backgroundInteractive == .yes {
                let objectValue = scene.responseType.properties[1].properties[0].float
                sceneTask.responseBackground = objectValue
            } else {
                sceneTask.responseBackground = nil
            }
            sceneTask.responseObject = Array(repeating: nil, count: sceneTask.numberOfMetals)
            for property in scene.responseType.properties {
                if let objectNumber = scene.movableObjects.firstIndex(where: { $0.id == property.somethingId }) {
                    let interactive = FixedObjectResponse(rawValue: property.string) ?? .no
                    if interactive == .yes {
                        let objectValue = property.properties[0].float
                        sceneTask.responseObject[objectNumber] = objectValue
                    }
                }
            }
        case .moveObject:
            sceneTask.responseStartInFrames = (scene.responseType.properties[0].float * frameRate).toInt
            sceneTask.responseOrigin = getOrigin2dValue(from: scene.responseType.properties[1])
            sceneTask.responseCoordinates = FixedPositionResponse(rawValue: scene.responseType.properties[2].string) ??
                .cartesian
            sceneTask.responseFirstUnit = Unit(rawValue: scene.responseType.properties[2].properties[0].string) ??
                .none
            sceneTask.responseSecondUnit = Unit(rawValue: scene.responseType.properties[2].properties[1].string) ??
                .none
            sceneTask.endPath = FixedEndPath(rawValue: scene.responseType.properties[3].string) ?? .lift
            sceneTask.responseObject = Array(repeating: nil, count: sceneTask.numberOfMetals)
            for property in scene.responseType.properties {
                if let objectNumber = scene.movableObjects.firstIndex(where: { $0.id == property.somethingId }) {
                    let interactive = FixedObjectResponse(rawValue: property.string) ?? .no
                    if interactive == .yes {
                        let objectValue = property.properties[0].float
                        sceneTask.responseObject[objectNumber] = objectValue
                    }
                }
            }
        }

        if let section = scene.section {
            if section.responseValue.somethingId == scene.id { //we are in the scene response
                sceneTask.isResponse = true
            }
        }
    }

    // MARK: - Helper functions
    private func checkNumberOfDots(objectNumber: Int) -> String {
        //width is always the large direction, we are calculating number from a density of dots in a 1x1 pixel square
        let pixelSquare = Flow.shared.settings.width * Flow.shared.settings.height

        for i in 0 ..< sceneTask.metalFloats.count {
            sceneTask.metalFloats[i][objectNumber][MetalValues.imageTextVideoDots] *= pixelSquare
            if sceneTask.metalFloats[i][objectNumber][MetalValues.imageTextVideoDots].toInt >
                Constants.maxNumberOfDots {
                return "ERROR: the number of dots is too high, try to reduce the density of dots."
            }
        }
        return ""
    }
}
