//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

enum TypeData {

    case activatedBools
    case start
    case duration

    case timeDependent

    case metal
    case audio
    case video
    case text
    case pureTone

    case image

    case background
}

class DependentVariable {

    var type: TypeData
    var objectNumber: Int
    var position: Int
    var values: Int
    var repetitions: Int
    var method: FixedCorrectType
    var dependentValue: Int = 0
    var previousDependentSum: Int = 0
    var update: Update?
    var parameter: Int?
    var polarRadius: Bool
    var polarAngle: Bool
    var changingSize: Bool = false
    var changingPosition: Bool = false
    var variableTask: VariableTask
    var starting = true

    init(type: TypeData,
         objectNumber: Int,
         position: Int,
         values: Int,
         repetitions: Int,
         method: FixedCorrectType,
         update: Update? = nil,
         parameter: Int? = nil,
         polarRadius: Bool = false,
         polarAngle: Bool = false,
         variableTask: VariableTask) {

        self.type = type
        self.objectNumber = objectNumber
        self.position = position
        self.values = values
        self.repetitions = repetitions
        self.method = method
        self.update = update
        self.parameter = parameter
        self.polarRadius = polarRadius
        self.polarAngle = polarAngle
        self.variableTask = variableTask
    }

    var initialValue: Int {
        return variableTask.initialValue
    }

    var list: ListOfValues {
        return variableTask.list
    }
}

class Update {

    var position: Int = 0
    var objectNumber: Int = 0
    var type: TypeData = .background
    var repetitions: Int = 1
    var polar: Bool = false
    var parameters: [[Float]] = [] //trial * variable
    var parameters1: [[Float]] = [] //for polar variables
    var function: ([Float], Float) -> (Float) = { c, _ in return c[0] }
    var function1: ([Float], Float) -> (Float) = { c, _ in return c[0] }

    init() {}

    func changeValues(sceneTask: SceneTask, trial: Int, timeInFrames: Int) {

        let time = Float(timeInFrames) * Flow.shared.settings.delta

        if polar {
            switch type {
            case .metal:
                var radius: Float = 0
                var angle: Float = 0
                if parameters.count > trial {
                    radius = function(parameters[trial], time)
                }
                if parameters1.count > trial {
                    angle = function1(parameters1[trial], time)
                }
                let (x, y) = AppUtility.polarToCartesian(radius: radius, angle: angle)
                sceneTask.metalFloats[trial][objectNumber][position] = x
                sceneTask.metalFloats[trial][objectNumber][position + 1] = y
            default:
                break
            }
        } else {
            let result = function(parameters[trial], time)
            switch type {
            case .background:
                for i in position ..< position + repetitions {
                    sceneTask.backgroundFloats[trial][i] = result
                }
            case .metal:
                for i in position ..< position + repetitions {
                    sceneTask.metalFloats[trial][objectNumber][i] = result
                }
            default:
                break
            }
        }
    }
}

class SceneTask {

    enum Action {
        case endScene
        case startText
        case endText
//        case startAudio
//        case endAudio
//        case endAudioTotal
        case startVideo
        case endVideo
        case startSineWave
        case endSineWave
    }

    enum CheckPointType {
        case endScene
        case text
        case audio
        case video
        case sineWave
    }

    struct CheckPoint {
        let time: Int
        let action: Action
        let objectNumber: Int
        let type: CheckPointType
    }

    var id: String = ""
    var name: String = ""
    var calculateLongFrames: Bool = true
    var seeds: [Seed] = [] //trial

    var activatedBools: [[Bool]] = [] //trial * object
    var startTimesInFrames: [[Int]] = [] //trial * object
    var durationTimesInFrames: [[Int]] = [] //trial * object
    var endTimesInFrames: [[Int]] = [] //trial * object
    var xSizeMax: [[Float]] = [] //trial * object
    var ySizeMax: [[Float]] = [] //trial * object
    var xSizeMax0: [[Float]] = [] //trial * object
    var ySizeMax0: [[Float]] = [] //trial * object
    var xCenter0: [[Float]] = [] //trial * object
    var yCenter0: [[Float]] = [] //trial * object
    var active: [[Int]] = [] //trial * object

    var numberOfLayers: Int = 1
    var continuousResolution = false

    var backgroundFloats: [[Float]] = [] //trial * variable
    var metalFloats: [[[Float]]] = [] //trial * object * variable
    var sineWaveFloats: [[Float]] = [] //trial * all objects and variables
    var textObjects: [[TextObject]] = [] //trial * object
    var videoObjects: [[VideoObject]] = [] //trial * object
//    var audioObjects: [[AudioObject]] = [] //trial * object
    var sineWaveObjects: [[SineWaveObject]] = [] //trial * object
    var images: [[Int]] = [] //trial * object

    var numberOfTrials: Int = 1
    var numberOfMetals: Int = 0

    var updates: [Update] = []

    var durationType: FixedDuration = .constant

    var checkPoints: [[CheckPoint]] = [] //trial * checkPoint

    var dependentVariables: [DependentVariable] = []

    var responseType: FixedResponse = .none
    var endPath: FixedEndPath = .lift
    var responseCoordinates: FixedPositionResponse = .cartesian
    var responseFirstUnit: Unit = .none
    var responseSecondUnit: Unit = .none
    var responseStartInFrames: Int = 0
    var responseOrigin: (x: Float, y: Float) = (0, 0)
    var responseObject: [Float?] = [] //object or left right or up bottom
    var responseKeyboard: FixedKeyboard = .normal
    var responseInTitle: Bool = false
    var responseBackground: Float?
    var responseKeys: [(String, String)] = []

    var isResponse: Bool = false

    var userResponses: [UserResponse] = [] //trial
    var durationInFrames: [Int] = [] //trial
    var realStartTime: [Double] = [] // trial
    var realEndTime: [Double] = [] // trial

    var dotsBorder: Bool = false

    var computeNumber: Int {
        return continuousResolution ? numberOfLayers + 2 : numberOfLayers - 1
    }

    func saveSceneData(timeInFrames: Int, startTime: Double, trial: Int) {

        userResponses.append(Task.shared.userResponse)

        durationInFrames.append(timeInFrames)
        realStartTime.append(startTime)
        realEndTime.append(CACurrentMediaTime() - startTime)

        if isResponse {
            let valueType = Task.shared.sectionTask.sectionValueType
            var distance: Float?

            if let valueType = valueType {
                switch valueType {

                case .value:
                    let value = Task.shared.sectionTask.sectionValues[trial]
                    if let response = Task.shared.userResponse.float {
                        distance = abs(response - value)
                    } else if let response = Task.shared.userResponse.string {
                        if let float = Float(response) {
                            distance = abs(float - value)
                        }
                    }
                case .position:
                    let valueX = Task.shared.sectionTask.sectionValues[trial]
                    let valueY = Task.shared.sectionTask.sectionValues1[trial]

                    let positionX = Task.shared.userResponse.xTouches.last
                    let positionY = Task.shared.userResponse.yTouches.last

                    if let positionX = positionX, let positionY = positionY {
                        let position = (positionX, positionY)
                        let value = (valueX, valueY)

                        distance = AppUtility.calculateDistance(position, value)
                    }
                case .xPosition:
                    let valueX = Task.shared.sectionTask.sectionValues[trial]
                    if let positionX = Task.shared.userResponse.xTouches.last {
                        distance = abs(positionX - valueX)
                    }
                case .yPosition:
                    let valueY = Task.shared.sectionTask.sectionValues[trial]
                    if let positionY = Task.shared.userResponse.yTouches.last {
                        distance = abs(positionY - valueY)
                    }
                case .radiusPosition:
                    let valueRadius = Task.shared.sectionTask.sectionValues[trial]
                    if let positionRadius = Task.shared.userResponse.radiusTouches.last {
                        distance = abs(positionRadius - valueRadius)
                    }
                case .anglePosition:
                    let valueAngle = Task.shared.sectionTask.sectionValues[trial]
                    if let positionAngle = Task.shared.userResponse.angleTouches.last {
                        distance = abs(positionAngle - valueAngle)
                    }
                }

            }

            if let distance = distance {
                if distance < Task.shared.sectionTask.sectionValueDifference {
                    Task.shared.sectionTask.last = 1
                } else {
                    Task.shared.sectionTask.last = 0
                }
            } else {
                Task.shared.sectionTask.last = 0
            }
        }
    }
}
