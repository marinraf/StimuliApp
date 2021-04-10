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
        case startVideo
        case endVideo
        case startSound
        case endSound
    }

    enum CheckPointType {
        case endScene
        case text
        case video
        case audio
    }

    struct CheckPoint {
        let time: Int
        let action: Action
        let objectNumber: Int
        let type: CheckPointType
    }

    var id: String = ""
    var name: String = ""
    var frameControl: Bool = true
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
    var audioFloats: [[Float]] = [] //trial * all objects and variables
    var textObjects: [[TextObject]] = [] //trial * object
    var videoObjects: [[VideoObject]] = [] //trial * object
    var audioObjects: [[AudioObject]] = [] //trial * object
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
    var responseStart: Double = 0
    var responseEnd: Double = 0
    var responseOutWindow: Bool = false
    var responseOrigin: (x: Float, y: Float) = (0, 0)
    var responseObject: [Float?] = [] //object or left right or up bottom or one value for lift
    var responseKeyboard: FixedKeyboard = .normal
    var responseInTitle: Bool = false
    var responseBackground: Float?
    var responseKeys: [(String, String)] = []

    var isNotRealResponse: Bool = true
    var isRealResponse: Bool = false

    var userResponses: [UserResponse] = [] //trial
    var realStartTime: [Double] = [] // trial
    var realEndTime: [Double] = [] // trial
    var delayTime: [Double] = [] // trial

    var dotsBorder: Bool = false

    var badTiming: Bool = false
    var computeNumber: Int {
        return continuousResolution ? numberOfLayers + 2 : numberOfLayers - 1
    }

    func saveSceneTime(time: Double) {
        let count = realEndTime.count
        if count > 0 {
            realEndTime[count - 1] = time
        }
    }

    func saveSceneData(startTime: Double, startTimeReal: Double, trial: Int) {

        userResponses.append(Task.shared.userResponse)

        realStartTime.append(startTime)
        realEndTime.append(startTime)
        delayTime.append(max((startTimeReal - startTime), 0))

        if isNotRealResponse || isRealResponse {

            if Task.shared.sceneTask.badTiming || Task.shared.userResponse.string == nil {
                Task.shared.sectionTask.respondedInTime = false
            }
        }

        if isRealResponse {

            let valueType = Task.shared.sectionTask.sectionValueType
            var distance: Float?

            if let valueType = valueType {

                var value1: Float = 0

                if Task.shared.sectionTask.sectionValues.count > trial {
                    value1 = Task.shared.sectionTask.sectionValues[trial]
                }

                switch valueType {
                case .value:
                    if let response = Task.shared.userResponse.float {
                        distance = abs(response - value1)
                    } else if let response = Task.shared.userResponse.string {
                        if let float = Float(response) {
                            distance = abs(float - value1)
                        }
                    }
                case .position:
                    let positionX = Task.shared.userResponse.xTouches.last
                    let positionY = Task.shared.userResponse.yTouches.last
                    let value2 = Task.shared.sectionTask.sectionValues1[trial]

                    if let positionX = positionX, let positionY = positionY {
                        let position = (positionX, positionY)
                        let value = (value1, value2)

                        distance = AppUtility.calculateDistance(position, value)
                    }
                case .xPosition:
                    if let positionX = Task.shared.userResponse.xTouches.last {
                        distance = abs(positionX - value1)
                    }
                case .yPosition:
                    if let positionY = Task.shared.userResponse.yTouches.last {
                        distance = abs(positionY - value1)
                    }
                case .radiusPosition:
                    if let positionRadius = Task.shared.userResponse.radiusTouches.last {
                        distance = abs(positionRadius - value1)
                    }
                case .anglePosition:
                    if let positionAngle = Task.shared.userResponse.angleTouches.last {
                        distance = abs(positionAngle - value1)
                    }
                }

                if distance == nil {
                    if let defaultNoResponse = Task.shared.sectionTask.defaultValueNoResponse {
                        distance = abs(defaultNoResponse - value1)
                        Task.shared.userResponse.string = String(defaultNoResponse)
                    }
                }
            }

            if let distance = distance {
                if Task.shared.userResponse.string == nil {
                    Task.shared.sectionTask.last = 0
                } else if distance < Task.shared.sectionTask.sectionValueDifference {
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
