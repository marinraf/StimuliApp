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
    var gazeFixation = false
    var distanceFixation = false
    var maxGazeErrorInPixels: Float = 0
    var maxDistanceErrorInCm: Float = 0
    var minDistanceErrorInCm: Float = 0

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
    var responseObjectInteractive: [Bool] = []
    var responseKeyboard: FixedKeyboard = .normal
    var responseInTitle: Bool = false
    var responseBackground: Float?
    var responseKeys: [(String, String)] = []
    var responseDistance: FixedResponseDistance = .module
    var responseMobile: FixedEndPathValues = .mobile
    var responseDimensions: Int = 2

    var isNotRealResponse: Bool = true
    var isRealResponse: Bool = false

    var userResponses: [UserResponse] = [] //trial
    var trackerResponses: [TrackerResponse] = [] //trial
    var distanceResponses: [DistanceResponse] = [] //trial
    var realStartTime: [Double] = [] // trial
    var realEndTime: [Double] = [] // trial

    var dotsBorder: Bool = false

    var badTiming: Bool = false
    var computeNumber: Int {
        return continuousResolution ? numberOfLayers + 2 : numberOfLayers - 1
    }

    func saveSceneData(trial: Int) {

        userResponses.append(Task.shared.userResponse)
        
        if isNotRealResponse || isRealResponse {

            if Task.shared.sceneTask.badTiming || Task.shared.userResponse.string == nil {
                Task.shared.sectionTask.respondedInTime = false
            }

            if Task.shared.sceneTask.badTiming && Task.shared.userResponse.string != nil {
                Task.shared.sectionTask.respondedOutTime = true
            }
        }

        if responseType == .twoFingersTouch {

            switch responseDistance {
            case .module:
                if let pos1 = Task.shared.userResponse.xTouches.last,
                   let pos2 = Task.shared.userResponse.yTouches.last,
                   let pos3 = Task.shared.userResponse.xTouch2,
                   let pos4 = Task.shared.userResponse.yTouch2 {
                    let dist = AppUtility.calculateDistance((pos1, pos2), (pos3, pos4))
                    userResponses[trial].float = dist
                    userResponses[trial].string = String(dist)
                }
            case .x:
                if let pos1 = Task.shared.userResponse.xTouches.last,
                   let pos2 = Task.shared.userResponse.xTouch2 {
                    let dist = abs(pos1 - pos2)
                    userResponses[trial].float = dist
                    userResponses[trial].string = String(dist)
                }
            case .y:
                if let pos1 = Task.shared.userResponse.yTouches.last,
                   let pos2 = Task.shared.userResponse.yTouch2 {
                    let dist = abs(pos1 - pos2)
                    userResponses[trial].float = dist
                    userResponses[trial].string = String(dist)
                }
            case .radius:
                if let pos1 = Task.shared.userResponse.radiusTouches.last,
                   let pos2 = Task.shared.userResponse.radiusTouch2 {
                    let dist = abs(pos1 - pos2)
                    userResponses[trial].float = dist
                    userResponses[trial].string = String(dist)
                }
            case .angle:
                if let pos1 = Task.shared.userResponse.angleTouches.last,
                   let pos2 = Task.shared.userResponse.angleTouch2 {
                    let dist = AppUtility.calculateDistanceAngle(pos1, pos2)
                    userResponses[trial].float = dist
                    userResponses[trial].string = String(dist)
                }
            }


        } else if responseType == .moveObject && endPath == .touch {

            switch responseMobile {
            case .mobile:
                if userResponses[trial].multipleFloats.count > 0 {
                    let value = userResponses[trial].multipleFloats[0]
                    Task.shared.userResponse.float = value
                    userResponses[trial].float = value
                    userResponses[trial].string = String(value)
                } else {
                    userResponses[trial].float = nil
                    userResponses[trial].string = "NaN"
                }
            case .stop:
                if userResponses[trial].multipleFloats.count > 1 {
                    let value = userResponses[trial].multipleFloats[1]
                    Task.shared.userResponse.float = value
                    userResponses[trial].float = value
                    userResponses[trial].string = String(value)
                } else {
                    userResponses[trial].float = nil
                    userResponses[trial].string = "NaN"
                }
            case .both:
                break
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
                case .positionVector:
                    switch responseCoordinates {
                    case .cartesian:
                        let positionX = Task.shared.userResponse.xTouches.last
                        let positionY = Task.shared.userResponse.yTouches.last
                        let value2 = Task.shared.sectionTask.sectionValues1[trial]

                        if let positionX = positionX, let positionY = positionY {
                            let position = (positionX, positionY)
                            let value = (value1, value2)
                            Task.shared.userResponse.string = "(\(positionX);\(positionY))"
                            userResponses[trial].string = "(\(positionX);\(positionY))"
                            distance = AppUtility.calculateDistance(position, value)
                        }
                    case .polar:
                        let positionRadius = Task.shared.userResponse.radiusTouches.last
                        let positionAngle = Task.shared.userResponse.angleTouches.last
                        let value2 = Task.shared.sectionTask.sectionValues1[trial]

                        if let positionRadius = positionRadius, let positionAngle = positionAngle {
                            let position = (positionRadius, positionAngle)
                            let value = (value1, value2)
                            Task.shared.userResponse.string = "(\(positionRadius);\(positionAngle))"
                            userResponses[trial].string = "(\(positionRadius);\(positionAngle))"
                            distance = AppUtility.calculateDistancePolar(position, value)
                        }
                    }
                case .positionX:
                    if let positionX = Task.shared.userResponse.xTouches.last {
                        distance = abs(positionX - value1)
                        Task.shared.userResponse.float = positionX
                        Task.shared.userResponse.string = String(positionX)
                        userResponses[trial].float = positionX
                        userResponses[trial].string = String(positionX)
                    }
                case .positionY:
                    if let positionY = Task.shared.userResponse.yTouches.last {
                        distance = abs(positionY - value1)
                        Task.shared.userResponse.float = positionY
                        Task.shared.userResponse.string = String(positionY)
                        userResponses[trial].float = positionY
                        userResponses[trial].string = String(positionY)
                    }
                case .positionRadius:
                    if let positionRadius = Task.shared.userResponse.radiusTouches.last {
                        distance = abs(positionRadius - value1)
                        Task.shared.userResponse.float = positionRadius
                        Task.shared.userResponse.string = String(positionRadius)
                        userResponses[trial].float = positionRadius
                        userResponses[trial].string = String(positionRadius)
                    }
                case .positionAngle:
                    if let positionAngle = Task.shared.userResponse.angleTouches.last {
                        distance = AppUtility.calculateDistanceAngle(positionAngle, value1)
                        Task.shared.userResponse.float = positionAngle
                        Task.shared.userResponse.string = String(positionAngle)
                        userResponses[trial].float = positionAngle
                        userResponses[trial].string = String(positionAngle)
                    }
                case .distanceModule, .distanceX, .distanceY, .distanceRadius, .distanceAngle:
                    if let dist = userResponses[trial].float {
                        distance = abs(dist - value1)
                        Task.shared.userResponse.float = dist
                        Task.shared.userResponse.string = String(dist)
                    }
                case .values:
                    let valueType2 = Task.shared.sectionTask.sectionValueType2
                    switch valueType2 {
                    case .vector2, .vector2Sorted:
                        if Task.shared.userResponse.multipleFloats.count == 2 {
                            let x = Task.shared.userResponse.multipleFloats[0]
                            let y = Task.shared.userResponse.multipleFloats[1]

                            let value2 = Task.shared.sectionTask.sectionValues1[trial]

                            let value = (value1, value2)

                            let position = (x, y)

                            distance = AppUtility.calculateDistance(position, value)

                            if valueType2 == .vector2 {

                                let position2 = (y, x)

                                let distance2 = AppUtility.calculateDistance(position2, value)

                                if let distanceReal = distance {
                                    distance = min(distanceReal, distance2)
                                }
                            }
                        }
                    case .vector3, .vector3Sorted:
                        if Task.shared.userResponse.multipleFloats.count == 3 {
                            let x = Task.shared.userResponse.multipleFloats[0]
                            let y = Task.shared.userResponse.multipleFloats[1]
                            let z = Task.shared.userResponse.multipleFloats[2]

                            let value2 = Task.shared.sectionTask.sectionValues1[trial]
                            let value3 = Task.shared.sectionTask.sectionValues2[trial]

                            let value = (value1, value2, value3)

                            let position = (x, y, z)

                            distance = AppUtility.calculateDistance3d(position, value)

                            if valueType2 == .vector3 {

                                let position2 = (x, z, y)
                                let position3 = (y, x, z)
                                let position4 = (y, z, x)
                                let position5 = (z, x, y)
                                let position6 = (z, y, x)

                                let distance2 = AppUtility.calculateDistance3d(position2, value)
                                let distance3 = AppUtility.calculateDistance3d(position3, value)
                                let distance4 = AppUtility.calculateDistance3d(position4, value)
                                let distance5 = AppUtility.calculateDistance3d(position5, value)
                                let distance6 = AppUtility.calculateDistance3d(position6, value)

                                if let distanceReal = distance {
                                    distance = min(distanceReal, distance2, distance3, distance4, distance5, distance6)
                                }
                            }
                        }
                    case .none:
                        break
                    }
                }

                if distance == nil {
                    if let defaultNoResponse = Task.shared.sectionTask.defaultValueNoResponse {
                        distance = abs(defaultNoResponse - value1)
                        Task.shared.userResponse.float = defaultNoResponse
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

