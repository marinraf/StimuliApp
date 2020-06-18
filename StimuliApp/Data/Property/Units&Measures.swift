//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

enum Unit: String, Codable, CaseIterable {
    case pixel = "pixels"
    case cm = "centimeters"
    case inch = "inches"
    case visualAngleDegree = "visual degrees"
    case hz = "hertzs"
    case second = "seconds"
    case frame = "frames"
    case cdm2 = "decimal value from 0 to 1"
    case maxcdm2 = "candelas per m²"
    case angleDegree = "degrees"
    case angleRad = "radians"
    case ppi = "pixels per inch"
    case ppcm = "pixels per cm"
    case none = ""
    case screenWidthUnits = "screen width units"
    case screenHeightUnits = "screen height units"


    var name: String {
        return self.rawValue
    }

    var info: String {
        let property = Flow.shared.settings.resolutionProperty
        switch self {
        case .pixel:
            let resolution = property.express(as: .pixel)
            return "Screen resolution in landscape mode: \(resolution)."
        case .cm:
            let resolution = property.express(as: .cm)
            return "Screen resolution in landscape mode: \(resolution)."
        case .inch:
            let resolution = property.express(as: .inch)
            return "Screen resolution in landscape mode: \(resolution)."
        case .visualAngleDegree:
            let resolution = property.express(as: .visualAngleDegree)
            let distance = Flow.shared.test.distance.properties[0].string
            let string1 = "Screen resolution in landscape mode: \(resolution)."
            let string2 = "Considering that the viewing distance for this test is: \(distance)."
            return string1 + "\n\n" + string2
        case .hz: return ""
        case .second: return ""
        case .frame:
            let string1 = "Frame rate of the test is set to: \(Flow.shared.settings.frameRate) Hz."
            let string2 = "The duration of one frame is: \(Flow.shared.settings.delta) seconds."
            return string1 + "\n\n" + string2
        case .cdm2:
            return """
            The maximum value of luminance set for this decive is: \(Flow.shared.settings.maximumBrightness) cd/m²
            """
        case .maxcdm2:
            if Flow.shared.settings.maximumBrightnessApple > 1 {
                return """
                The value that Apple provides for this device is: \(Flow.shared.settings.maximumBrightnessApple) cd/m²
                """
            } else {
                return ""
            }
        case .angleDegree: return ""
        case .angleRad: return ""
        case .ppi: return ""
        case .ppcm: return ""
        case .none: return ""
        case .screenWidthUnits:
            let string1 = "Screen width units from -1 to 1."
            let string2 = "Being width the width size of the screen in landscape mode."
            return string1 + "\n\n" + string2
        case .screenHeightUnits:
            let string1 = "Screen height units from -1 to 1."
            let string2 = "Being height the height size of the screen in landscape mode."
            return string1 + "\n\n" + string2
        }
    }

    var si: String {
        switch self {
        case .pixel: return "pixels"
        case .cm: return "cm"
        case .inch: return "in"
        case .visualAngleDegree: return "º"
        case .hz: return "Hz"
        case .second: return "s"
        case .frame: return "frames"
        case .cdm2: return ""
        case .maxcdm2: return "cd/m²"
        case .angleDegree: return "º"
        case .angleRad: return "rad"
        case .ppi: return "ppi"
        case .ppcm: return "ppcm"
        case .none: return ""
        case .screenWidthUnits: return ""
        case .screenHeightUnits: return ""
        }
    }

    var factor: Float {
        switch self {
        case .pixel: return 1
        case .cm: return Flow.shared.settings.ppcm
        case .inch: return Flow.shared.settings.ppi
        case .visualAngleDegree: return Flow.shared.settings.ppVisualAngleDegree
        case .hz: return 1
        case .second: return 1
        case .frame: return Flow.shared.settings.delta
        case .cdm2: return 1
        case .maxcdm2: return 1
        case .angleDegree: return Flow.shared.settings.radiansPerDegree
        case .angleRad: return 1
        case .ppcm: return Flow.shared.settings.cmPerPixel
        case .ppi: return Flow.shared.settings.inchPerPixel
        case .none: return 1
        case .screenWidthUnits: return Flow.shared.settings.width / 2
        case .screenHeightUnits: return Flow.shared.settings.height / 2
        }
    }
}

enum UnitType: String, Codable, CaseIterable {
    case variableUnit = "same unit as the variable it is applied to"
    case responseUnit = "same unit as the response"
    case decimal = "decimal value"
    case positiveDecimalWithoutZero = "positive non-zero decimal value"
    case positiveDecimalOrZero = "positive decimal value"
    case integer = "integer value"
    case positiveIntegerWithoutZero = "positive non-zero integer value"
    case positiveIntegerOrZero = "positive integer value"
    case activated = "0 or 1"

    case valueFrom0to1 = "decimal value from 0 to 1"
    case valueFrom3to10 = "integer value from 3 to 10"
    case valueFrom0to255 = "integer value from 0 to 255"

    case size = "size"
    case angle = "angle"
    case time = "time"

    case brightness = "brightness 0-1"
    case maxBrightness = "brightness in cd per m²"

    case externalSize = "external size"
    case rampTime = "ramp time"
    case delayTime = "delay time"
    case pixelDensity = "pixel density"
    case pixelSize = "pixel size"
    case diagonalSize = "diagonal size"
    case frequency = "frequency"

    var name: String {
        return self.rawValue
    }

    var possibleUnits: [Unit] {
        switch self {
        case .variableUnit: return [.none]
        case .responseUnit: return [.none]
        case .decimal: return [.none]
        case .integer: return [.none]
        case .positiveDecimalWithoutZero: return [.none]
        case .positiveIntegerWithoutZero: return [.none]
        case .positiveDecimalOrZero: return [.none]
        case .positiveIntegerOrZero: return [.none]
        case .activated: return [.none]

        case .valueFrom0to1: return [.none]
        case .valueFrom3to10: return [.none]
        case .valueFrom0to255: return [.none]

        case .size: return [.pixel, .cm, .inch, .visualAngleDegree, .screenWidthUnits, .screenHeightUnits]
        case .angle: return [.angleRad, .angleDegree]
        case .time: return [.second, .frame]

        case .brightness: return [.cdm2]
        case .maxBrightness: return [.maxcdm2]

        case .externalSize: return [.cm, .inch]
        case .rampTime: return [.second]
        case .delayTime: return [.second]
        case .pixelDensity: return [.ppi]
        case .pixelSize: return [.pixel]
        case .diagonalSize: return [.cm, .inch]
        case .frequency: return [.hz]
        }
    }

    var referenceUnit: Unit {
        return possibleUnits[0]
    }

    func delimit(float: Float) -> Float {
        switch self {
        case .decimal, .size, .variableUnit, .responseUnit, .delayTime:
            return float
        case .positiveDecimalWithoutZero:
            return max(Constants.epsilon, abs(float))
        case .externalSize, .pixelDensity, .diagonalSize:
            return max(1, abs(float))
        case .pixelSize:
            return max(Constants.minimumResolutionMac, abs(float))
        case .positiveDecimalOrZero, .time, .rampTime:
            return abs(float)
        case .valueFrom0to1:
            if float < 0 {
                return 0
            } else if float > 1 {
                return 1
            } else {
                return float
            }
        case .valueFrom3to10:
            if float < 3 {
                return 3
            } else if float > 10 {
                return 10
            } else {
                return roundf(float)
            }
        case .valueFrom0to255:
            if float < 0 {
                return 0
            } else if float > 255 {
                return 255
            } else {
                return Float(roundf(float))
            }
        case .brightness:
            if float < 0.25 {
                return 0.25
            } else if float > 1 {
                return 1
            } else {
                return float
            }
        case .maxBrightness:
            if float < Constants.epsilon {
                return Constants.epsilon
            } else if float > 3000 {
                return 3000
            } else {
                return float
            }
        case .integer:
            return roundf(float)
        case .positiveIntegerWithoutZero, .frequency:
            return max(1, abs(roundf(float)))
        case .positiveIntegerOrZero:
            return abs(roundf(float))
        case .activated:
            if float < 0.5 {
                return 0
            } else {
                return 1
            }
        case .angle:
            if float >= 0 {
                return float.truncatingRemainder(dividingBy: 2 * Float.pi)
            } else {
                return float.truncatingRemainder(dividingBy: 2 * Float.pi) + 2 * Float.pi
            }
        }
    }
}

enum TimeDependency: String, Codable, CaseIterable {

    case alwaysConstant = ""
    case constant = "constant"
    case variable = "variable"
    case timeDependent = "time dependent"

    var name: String {
        return rawValue
    }
}

enum PropertyType: String, Codable, CaseIterable {

    case simpleFloat

    case simpleFloatText

    case string
    case key

    case select
    case type
    case shape
    case border
    case noise
    case contrast
    case modulator

    case response
    case sceneDuration
    case objectResponse
    case keyResponse
    case distance
    case randomness
    case gamma
    case listOrder
    case selection
    case selectionDifferent
    case selectionOrder
    case correctType

    case origin2d
    case originResponse
    case position2d
    case positionResponse
    case value
    case valueType
    case correct
    case size2d
    case color

    case behaviour
    case direction

    case soundType

    case font

    case dobleSize
    case doblePosition
    case triple
    case sequence

    case image
    case text
    case video
    case audio

    case timeFloat

    case finalFloat

    var timeDependencies: [TimeDependency] {
        switch self {
        case .simpleFloat: return [.alwaysConstant]
        case .simpleFloatText: return [.constant, .variable]
        case .string: return [.alwaysConstant]
        case .key: return [.alwaysConstant]
        case .select: return [.alwaysConstant]
        case .type: return [.alwaysConstant]
        case .shape: return [.alwaysConstant]
        case .border: return [.alwaysConstant]
        case .noise: return [.alwaysConstant]
        case .contrast: return [.alwaysConstant]
        case .modulator: return [.alwaysConstant]
        case .response: return [.alwaysConstant]
        case .sceneDuration: return [.alwaysConstant]
        case .objectResponse: return [.alwaysConstant]
        case .keyResponse: return [.alwaysConstant]
        case .distance: return [.alwaysConstant]
        case .randomness: return [.alwaysConstant]
        case .gamma: return [.alwaysConstant]
        case .listOrder: return [.alwaysConstant]
        case .selection: return [.alwaysConstant]
        case .selectionDifferent: return [.alwaysConstant]
        case .selectionOrder: return [.alwaysConstant]
        case .origin2d: return [.alwaysConstant]
        case .originResponse: return [.alwaysConstant]
        case .position2d: return [.alwaysConstant]
        case .positionResponse: return [.alwaysConstant]
        case .value: return [.alwaysConstant]
        case .valueType: return [.alwaysConstant]
        case .correct: return [.alwaysConstant]
        case .correctType: return [.alwaysConstant]
        case .size2d: return [.alwaysConstant]
        case .color: return [.alwaysConstant]
        case .behaviour: return [.alwaysConstant]
        case .direction: return [.alwaysConstant]
        case .soundType: return [.alwaysConstant]
        case .font: return [.alwaysConstant]
        case .dobleSize: return [.constant, .variable]
        case .doblePosition: return [.constant, .variable]
        case .triple: return [.constant, .variable]
        case .sequence: return [.alwaysConstant]
        case .image: return [.constant, .variable]
        case .text: return [.constant, .variable]
        case .video: return [.constant, .variable]
        case .audio: return [.constant, .variable]
        case .timeFloat: return [.constant, .variable, .timeDependent]
        case .finalFloat: return [.constant, .variable]
        }
    }

    var numberKeyboard: Bool {
        switch self {
        case .simpleFloat: return true
        case .simpleFloatText: return true
        case .string: return false
        case .key: return false
        case .select: return false
        case .type: return false
        case .shape: return false
        case .border: return false
        case .noise: return false
        case .contrast: return false
        case .modulator: return false
        case .response: return false
        case .sceneDuration: return false
        case .objectResponse: return false
        case .keyResponse: return false
        case .distance: return false
        case .randomness: return false
        case .gamma: return false
        case .listOrder: return false
        case .selection: return false
        case .selectionDifferent: return false
        case .selectionOrder: return false
        case .origin2d: return false
        case .originResponse: return false
        case .position2d: return false
        case .positionResponse: return false
        case .value: return false
        case .valueType: return false
        case .correct: return false
        case .correctType: return false
        case .size2d: return false
        case .color: return false
        case .behaviour: return false
        case .direction: return false
        case .soundType: return false
        case .font: return false
        case .dobleSize: return true
        case .doblePosition: return true
        case .triple: return true
        case .sequence: return true
        case .image: return true
        case .text: return true
        case .video: return true
        case .audio: return true
        case .timeFloat: return true
        case .finalFloat: return true
        }
    }

    var fixedValues: [String] {
        switch self {
        case .simpleFloat: return []
        case .simpleFloatText: return []
        case .string: return []
        case .key: return []
        case .select: return []
        case .type: return StimuliType.allCases.map({ $0.name })
        case .shape: return StimulusShape.allCases.map({ $0.name })
        case .border:  return FixedBorder.allCases.map({ $0.name })
        case .noise: return FixedNoise.allCases.map({ $0.name })
        case .contrast: return FixedContrast.allCases.map({ $0.name })
        case .modulator: return FixedModulator.allCases.map({ $0.name })
        case .response: return FixedResponse.allCases.map({ $0.name })
        case .sceneDuration: return FixedDuration.allCases.map({ $0.name })
        case .objectResponse: return FixedObjectResponse.allCases.map({ $0.name })
        case .keyResponse: return FixedKeyResponse.allCases.map( { $0.name })
        case .distance: return FixedDistance.allCases.map({ $0.name })
        case .randomness: return FixedRandomness.allCases.map({ $0.name })
        case .listOrder: return FixedListOrder.allCases.map { $0.name }
        case .selection: return FixedSelection.allCases.map { $0.name }
        case .selectionDifferent: return FixedSelectionDifferent.allCases.map { $0.name }
        case .selectionOrder: return FixedSelectionPriority.allCases.map { $0.name }
        case .origin2d: return FixedOrigin2d.allCases.map({ $0.name })
        case .originResponse: return FixedOrigin2d.allCases.map({ $0.name })
        case .position2d: return FixedPosition2d.allCases.map({ $0.name })
        case .positionResponse: return FixedPositionResponse.allCases.map({ $0.name })
        case .size2d: return FixedSize2d.allCases.map({ $0.name })
        case .color: return FixedColor.allCases.map({ $0.name })
        case .behaviour: return FixedBehaviour.allCases.map({ $0.name })
        case .direction: return FixedDirection.allCases.map({ $0.name })
        case .soundType: return FixedSoundType.allCases.map({ $0.name })
        case .valueType: return FixedValueType.allCases.map({ $0.name })
        case .correctType: return FixedCorrectType.allCases.map({ $0.name })
        case .gamma: return FixedGamma.allCases.map({ $0.name })
        case .font: return []
        case .dobleSize: return []
        case .doblePosition: return []
        case .triple: return []
        case .sequence: return []
        case .image: return []
        case .text: return []
        case .video: return []
        case .audio: return []
        case .timeFloat: return []
        case .finalFloat: return []
        case .value: return []
        case .correct: return []
        }
    }

    var fixedValuesInfo: [String] {
        switch self {
        case .simpleFloat: return []
        case .simpleFloatText: return []
        case .string: return []
        case .key: return[]
        case .select: return []
        case .type: return StimuliType.allCases.map({ $0.description })
        case .shape: return StimulusShape.allCases.map({ $0.description })
        case .border:  return FixedBorder.allCases.map({ $0.description })
        case .noise: return FixedNoise.allCases.map({ $0.description })
        case .contrast: return FixedContrast.allCases.map({ $0.description })
        case .modulator: return FixedModulator.allCases.map({ $0.description })
        case .response: return FixedResponse.allCases.map({ $0.description })
        case .sceneDuration: return FixedDuration.allCases.map({ $0.description })
        case .objectResponse: return FixedObjectResponse.allCases.map({ $0.description })
        case .keyResponse: return FixedKeyResponse.allCases.map({ $0.description })
        case .distance: return FixedDistance.allCases.map({ $0.description })
        case .randomness: return FixedRandomness.allCases.map({ $0.description })
        case .listOrder: return FixedListOrder.allCases.map({ $0.description })
        case .selection: return FixedSelection.allCases.map { $0.description }
        case .selectionDifferent: return FixedSelectionDifferent.allCases.map { $0.description }
        case .selectionOrder: return FixedSelectionPriority.allCases.map { $0.description }
        case .origin2d: return FixedOrigin2d.allCases.map({ $0.description })
        case .originResponse: return FixedOrigin2d.allCases.map({ $0.description })
        case .position2d: return FixedPosition2d.allCases.map({ $0.description })
        case .positionResponse: return FixedPositionResponse.allCases.map({ $0.description })
        case .size2d: return FixedSize2d.allCases.map({ $0.description })
        case .color: return FixedColor.allCases.map({ $0.description })
        case .behaviour: return FixedBehaviour.allCases.map({ $0.description })
        case .direction: return FixedDirection.allCases.map({ $0.description })
        case .soundType: return FixedSoundType.allCases.map({ $0.description })
        case .valueType: return FixedValueType.allCases.map({ $0.description })
        case .correctType: return FixedCorrectType.allCases.map({ $0.description })
        case .gamma: return FixedGamma.allCases.map({ $0.description })
        case .font: return []
        case .dobleSize: return []
        case .doblePosition: return []
        case .triple: return []
        case .sequence: return []
        case .image: return []
        case .text: return []
        case .video: return []
        case .audio: return []
        case .timeFloat: return []
        case .finalFloat: return []
        case .value: return []
        case .correct: return []
        }
    }
}

enum Measure {

    case decimal
    case integer
    case positiveDecimalWithoutZero
    case positiveIntegerWithoutZero
    case positiveDecimalOrZero
    case positiveIntegerOrZero
    case valueFrom0to1

    case size
    case angle
    case time

    case position2d
    case size2d
    case color

    var unitType: UnitType {
        switch self {
        case .decimal: return .decimal
        case .integer: return .integer
        case .positiveDecimalWithoutZero: return .positiveDecimalWithoutZero
        case .positiveIntegerWithoutZero: return .positiveIntegerWithoutZero
        case .positiveDecimalOrZero: return .positiveDecimalOrZero
        case .positiveIntegerOrZero: return .positiveIntegerOrZero
        case .valueFrom0to1: return .valueFrom0to1
        case .size: return .size
        case .angle: return .angle
        case .time: return .time
        case .position2d: return .size
        case .size2d: return .size
        case .color: return .valueFrom0to1
        }
    }

    var propertyType: PropertyType {
        switch self {
        case .decimal: return .timeFloat
        case .integer: return .timeFloat
        case .positiveDecimalWithoutZero: return .timeFloat
        case .positiveIntegerWithoutZero: return .timeFloat
        case .positiveDecimalOrZero: return .timeFloat
        case .positiveIntegerOrZero: return .timeFloat
        case .valueFrom0to1: return .timeFloat
        case .size: return .timeFloat
        case .angle: return .timeFloat
        case .time: return .finalFloat
        case .position2d: return .position2d
        case .size2d: return .size2d
        case .color: return .color
        }
    }
}
