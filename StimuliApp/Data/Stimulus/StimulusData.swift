//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct StimulusData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.stimulusName,
                        text: text)
    }

    static func makeTypeProperty(type: StimuliType) -> Property {

        let index = StimuliType.allCases.firstIndex(of: type) ?? 0

        let property = Property(name: "type",
                                info: Texts.type,
                                propertyType: .type,
                                unitType: .decimal,
                                fixedValues: StimuliType.allCases.map({ $0.name }),
                                selectedValue: index)
        return property
    }

    static func makeShapeProperty(shape: StimulusShape) -> Property {

        let index = StimulusShape.allCases.firstIndex(of: shape) ?? 0

        let property = Property(name: "shape",
                                info: Texts.shape,
                                propertyType: .shape,
                                unitType: .decimal,
                                fixedValues: StimulusShape.allCases.map({ $0.name }),
                                selectedValue: index)
        return property
    }

    static func makeActivatedProperty(float: Float) -> Property {

        let activated = Property(name: "activated",
                                 info: Texts.activated,
                                 propertyType: .finalFloat,
                                 unitType: .activated,
                                 float: float)
        return activated
    }

    static func makeStartProperty(float: Float) -> Property {

        let start = Property(name: "start",
                             info: Texts.start,
                             propertyType: .finalFloat,
                             unitType: .time,
                             float: float)
        return start
    }

    static func makeDurationProperty(float: Float) -> Property {

        let duration = Property(name: "duration",
                                info: Texts.duration,
                                propertyType: .finalFloat,
                                unitType: .time,
                                float: float)
        return duration
    }

    static func makeOriginProperty(selected: Int) -> Property {

        let property = Property(name: "originCoordinates",
                                info: Texts.originCoordinates,
                                propertyType: .origin2d,
                                unitType: .decimal,
                                fixedValues: FixedOrigin2d.allCases.map({ $0.name }),
                                selectedValue: selected)
        return property
    }

    static func makePositionProperty(selected: Int) -> Property {

        let property = Property(name: "position",
                                info: Texts.position,
                                propertyType: .position2d,
                                unitType: .decimal,
                                fixedValues: FixedPosition2d.allCases.map({ $0.name }),
                                selectedValue: selected)
        return property
    }

    static func makeRotationProperty(float: Float) -> Property {

        let property = Property(name: "rotation",
                                info: Texts.rotation,
                                propertyType: .timeFloat,
                                unitType: .angle,
                                float: float)
        return property
    }

    static func makeBorderProperty(selected: Int) -> Property {

        let property = Property(name: "border",
                                info: Texts.border,
                                propertyType: .border,
                                unitType: .decimal,
                                fixedValues: FixedBorder.allCases.map { $0.name },
                                selectedValue: selected)
        return property
    }

    static func addPropertiesToBorder(property: Property) {

        property.properties = []

        if property.selectedValue != 0 {

            let borderDistance = Property(name: "borderDistance",
                                          info: Texts.borderDistance,
                                          propertyType: .timeFloat,
                                          unitType: .size,
                                          float: 0)

            let borderThickness = Property(name: "borderThickness",
                                           info: Texts.borderThickness,
                                           propertyType: .timeFloat,
                                           unitType: .size,
                                           float: 4)

            let borderColor = createProperty(name: "borderColor",
                                             info: Texts.borderColor,
                                             measure: .color,
                                             value: 0)

            property.properties.append(borderDistance)
            property.properties.append(borderThickness)
            property.properties.append(borderColor)
        }
    }

    static func makeNoiseProperty(selected: Int) -> Property {

        let property = Property(name: "noise",
                                info: Texts.noise,
                                propertyType: .noise,
                                unitType: .decimal,
                                fixedValues: FixedNoise.allCases.map { $0.name },
                                selectedValue: selected)
        return property
    }

    static func addPropertiesToNoise(property: Property) {

        property.properties = []

        let noiseDeviation = Property(name: "noiseDeviation",
                                      info: Texts.noiseDeviation,
                                      propertyType: .timeFloat,
                                      unitType: .positiveDecimalOrZero,
                                      float: 0.5)

        let noiseIntensity = Property(name: "noiseIntensity",
                                      info: Texts.noiseIntensity,
                                      propertyType: .timeFloat,
                                      unitType: .valueFrom0to1,
                                      float: 0.5)

        let noiseSmoothness = Property(name: "noiseSmoothness",
                                       info: Texts.noiseSmoothness,
                                       propertyType: .timeFloat,
                                       unitType: .valueFrom0to1,
                                       float: 0.5)

        let noiseTimePeriod = Property(name: "noiseTimePeriod",
                                       info: Texts.noiseTimePeriod,
                                       propertyType: .finalFloat,
                                       unitType: .time,
                                       float: 1)

        let noiseSize = Property(name: "noiseSize",
                                 info: Texts.noiseSize,
                                 propertyType: .size2d,
                                 unitType: .decimal,
                                 fixedValues: FixedSize2d.allCases.map({ $0.name }),
                                 selectedValue: 0,
                                 float: 10)

        let noisePosition = Property(name: "noisePosition",
                                     info: Texts.noisePosition,
                                     propertyType: .size2d,
                                     unitType: .decimal,
                                     fixedValues: FixedSize2d.allCases.map({ $0.name }),
                                     selectedValue: 0)

        let noiseRotation = Property(name: "noiseRotation",
                                     info: Texts.noiseRotation,
                                     propertyType: .timeFloat,
                                     unitType: .angle,
                                     float: 0)

        guard let selected = FixedNoise(rawValue: property.string) else { return }
        switch selected {
        case .none:
            break
        case .gaussian:
            property.properties.append(noiseDeviation)
            property.properties.append(noiseTimePeriod)
            property.properties.append(noisePosition)
            property.properties.append(noiseRotation)
            property.properties.append(noiseSize)
        case .perlin:
            property.properties.append(noiseIntensity)
            property.properties.append(noiseTimePeriod)
            property.properties.append(noisePosition)
            property.properties.append(noiseRotation)
            property.properties.append(noiseSmoothness)
        }
    }

    static func addPropertiesToDirection(property: Property) {

        property.properties = []

        let directionAngle = Property(name: "directionAngle",
                                      info: Texts.directionAngle,
                                      propertyType: .timeFloat,
                                      unitType: .angle,
                                      float: 0)

        let distance = Property(name: "distance",
                                      info: Texts.distanceDots,
                                      propertyType: .timeFloat,
                                      unitType: .size,
                                      float: 20)

        let distanceAngle = Property(name: "distanceAngle",
                                     info: Texts.distanceAngle,
                                     propertyType: .timeFloat,
                                     unitType: .angle,
                                     float: 0.5)

        guard let selected = FixedDirection(rawValue: property.string) else { return }
        switch selected {
        case .random:
            property.properties.append(distance)
        case .fixed:
            property.properties.append(distance)
            property.properties.append(directionAngle)
        case .center:
            property.properties.append(distance)
        case .outCenter:
            property.properties.append(distance)
        case .clockwise:
            property.properties.append(distanceAngle)
        case .counterclockwise:
            property.properties.append(distanceAngle)
        }

    }

    static func addPropertiesToSoundType(property: Property) {

        property.properties = []

        let frequency = Property(name: "frequency",
                                 info: "The frequency of the sinewave.",
                                 propertyType: .finalFloat,
                                 unitType: .frequency,
                                 float: 440)

        guard let selected = FixedSoundType(rawValue: property.string) else { return }
        switch selected {
        case .pureTone:
            property.properties.append(frequency)
        case .whiteNoise:
            break
        }

    }

    static func makeContrastProperty(selected: Int) -> Property {

        let property = Property(name: "contrast",
                                info: Texts.contrast,
                                propertyType: .contrast,
                                unitType: .decimal,
                                fixedValues: FixedContrast.allCases.map { $0.name },
                                selectedValue: selected)
        return property
    }

    static func addPropertiesToContrast(property: Property) {

        property.properties = []

        guard let selected = FixedContrast(rawValue: property.string) else { return }
        switch selected {
        case .uniform:
            let contrastValue = Property(name: "contrastValue",
                                         info: Texts.contrastValue,
                                         propertyType: .timeFloat,
                                         unitType: .valueFrom0to1,
                                         float: 1)

            property.properties.append(contrastValue)
        case .gaussian:
            let contrastValue = Property(name: "contrastValue",
                                         info: Texts.contrastValue2,
                                         propertyType: .timeFloat,
                                         unitType: .valueFrom0to1,
                                         float: 1)

            let contrastGaussianDeviation = Property(name: "contrastGaussianDeviation",
                                            info: Texts.contrastGaussianDeviation,
                                            propertyType: .timeFloat,
                                            unitType: .size,
                                            float: 100)

            property.properties.append(contrastValue)
            property.properties.append(contrastGaussianDeviation)
        case .cosine:
            let contrastValue = Property(name: "contrastValue",
                                         info: Texts.contrastValue2,
                                         propertyType: .timeFloat,
                                         unitType: .valueFrom0to1,
                                         float: 1)

            let contrastCosineValue = Property(name: "contrastCosineValue",
                                            info: Texts.contrastCosineValue,
                                            propertyType: .timeFloat,
                                            unitType: .valueFrom0to1,
                                            float: 0)

            property.properties.append(contrastValue)
            property.properties.append(contrastCosineValue)
        }
    }

    static func makeModulatorProperty(selected: Int) -> Property {

        let property = Property(name: "modulator",
                                info: Texts.modulator,
                                propertyType: .modulator,
                                unitType: .decimal,
                                fixedValues: FixedModulator.allCases.map { $0.name },
                                selectedValue: selected)
        return property
    }

    static func addPropertiesToModulator(property: Property) {

        property.properties = []

        if property.selectedValue != 0 {

            let modulatorAmplitude = Property(name: "modulatorAmplitude",
                                              info: Texts.modulatorAmplitude,
                                              propertyType: .timeFloat,
                                              unitType: .valueFrom0to1,
                                              float: 0.5)

            let modulatorPeriod = Property(name: "modulatorPeriod",
                                           info: Texts.modulatorPeriod,
                                           propertyType: .timeFloat,
                                           unitType: .size,
                                           float: 100)

            let modulatorPhase = Property(name: "modulatorPhase",
                                          info: Texts.modulatorPhase,
                                          propertyType: .timeFloat,
                                          unitType: .angle,
                                          float: 0)

            let modulatorRotation = Property(name: "modulatorRotation",
                                             info: Texts.modulatorRotation,
                                             propertyType: .timeFloat,
                                             unitType: .angle,
                                             float: 0)

            property.properties.append(modulatorAmplitude)
            property.properties.append(modulatorPeriod)
            property.properties.append(modulatorPhase)
            property.properties.append(modulatorRotation)
        }
    }

    static func addPropertiesToSize2d(property: Property) {

        property.properties = []

        guard let selected = FixedSize2d(rawValue: property.string) else { return }
        switch selected {
        case .vector2d:
            let propertyUnique = Property(name: property.name,
                                          info: "Horizontal size x Vertical size",
                                          propertyType: .dobleSize,
                                          unitType: .size,
                                          float: property.float)

            property.properties.append(propertyUnique)
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal size.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical size.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .xy:
            let propertySame = Property(name: property.name ,
                                        info: "X size = Y size.",
                                        propertyType: .timeFloat,
                                        unitType: .size,
                                        float: property.float)

            property.properties.append(propertySame)
        }
    }

    static func addPropertiesToOrigin2d(property: Property) {

        property.properties = []

        guard let selected = FixedOrigin2d(rawValue: property.string) else { return }
        switch selected {
        case .center:
            break
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal position.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical position.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .polar:
            let propertyRadius = Property(name: property.name + "Radius",
                                          info: "Radius position.",
                                          propertyType: .timeFloat,
                                          unitType: .size,
                                          float: property.float)

            let propertyAngle = Property(name: property.name + "Angle",
                                         info: "Angle position.",
                                         propertyType: .timeFloat,
                                         unitType: .angle,
                                         float: property.float)

            property.properties.append(propertyRadius)
            property.properties.append(propertyAngle)
        }
    }

    static func addPropertiesToPosition2d(property: Property) {

        property.properties = []

        guard let selected = FixedPosition2d(rawValue: property.string) else { return }
        switch selected {
        case .vector2d:
            let propertyUnique = Property(name: property.name,
                                          info: "Horizontal position - Vertical position",
                                          propertyType: .doblePosition,
                                          unitType: .size,
                                          float: property.float)

            property.properties.append(propertyUnique)
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal position.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical position.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: property.float)

            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .polar:
            let propertyRadius = Property(name: property.name + "Radius",
                                          info: "Radius position.",
                                          propertyType: .timeFloat,
                                          unitType: .size,
                                          float: property.float)

            let propertyAngle = Property(name: property.name + "Angle",
                                         info: "Angle position.",
                                         propertyType: .timeFloat,
                                         unitType: .angle,
                                         float: property.float)

            property.properties.append(propertyRadius)
            property.properties.append(propertyAngle)
        }
    }

    static func addPropertiesToColor(property: Property) {

        property.properties = []

        guard let selected = FixedColor(rawValue: property.string) else { return }
        switch selected {
        case .vector3d:
            let propertyUnique = Property(name: property.name,
                                          info: "Red - Green - Blue",
                                          propertyType: .triple,
                                          unitType: .valueFrom0to1,
                                          float: property.float)

            property.properties.append(propertyUnique)
        case .rgb:
            let propertyR = Property(name: property.name + "R",
                                     info: "Red value.",
                                     propertyType: .timeFloat,
                                     unitType: .valueFrom0to1,
                                     float: property.float)

            let propertyG = Property(name: property.name + "G",
                                     info: "Green value.",
                                     propertyType: .timeFloat,
                                     unitType: .valueFrom0to1,
                                     float: property.float)

            let propertyB = Property(name: property.name + "B",
                                     info: "Green value.",
                                     propertyType: .timeFloat,
                                     unitType: .valueFrom0to1,
                                     float: property.float)

            if property.name == "textColor" {
                propertyR.propertyType = .finalFloat
                propertyG.propertyType = .finalFloat
                propertyB.propertyType = .finalFloat
            }

            property.properties.append(propertyR)
            property.properties.append(propertyG)
            property.properties.append(propertyB)
        case .luminance:
            let propertyLuminance = Property(name: property.name + "Luminance",
                                             info: "Luminance value.",
                                             propertyType: .timeFloat,
                                             unitType: .valueFrom0to1,
                                             float: property.float)

            if property.name == "textColor" {
                propertyLuminance.propertyType = .finalFloat
            }

            property.properties.append(propertyLuminance)
        }
    }

    static func createProperty(name: String, info: String, measure: Measure, value: Float) -> Property {
        switch measure {
        case .position2d:
            return Property(name: name,
                            info: info,
                            propertyType: measure.propertyType,
                            unitType: measure.unitType,
                            fixedValues: FixedPosition2d.allCases.map({ $0.name }),
                            selectedValue: 0,
                            float: value)
        case .size2d:
            return Property(name: name,
                            info: info,
                            propertyType: measure.propertyType,
                            unitType: measure.unitType,
                            fixedValues: FixedSize2d.allCases.map({ $0.name }),
                            selectedValue: 0,
                            float: value)
        case .color:
            return Property(name: name,
                            info: info,
                            propertyType: measure.propertyType,
                            unitType: measure.unitType,
                            fixedValues: FixedColor.allCases.map({ $0.name }),
                            selectedValue: 0,
                            float: value)

        default:
            return Property(name: name,
                            info: info,
                            propertyType: measure.propertyType,
                            unitType: measure.unitType,
                            float: value)
        }
    }

    static func createProperty(for property: Property,
                               name: String,
                               info: String,
                               measureSame: Int,
                               measureTime: Int,
                               defaultValue: Float) -> Property {

        var newUnitType: UnitType = .decimal
        var newUnit: Unit = .none

        if measureSame == 0 && measureTime == 0 {
            newUnitType = .angle
            newUnit = .angleRad
        } else if measureSame == 1 && measureTime == 1 {
            newUnitType = property.unitType
            newUnit = property.unit
        } else if measureSame == 0 && measureTime == 1 {
            newUnitType = .positiveDecimalOrZero
            newUnit = .none
        } else if measureSame == 1 {
            newUnitType = .decimal
            newUnit = property.unit
        }

        let newProperty = Property(name: property.name + name.capitalizingFirstLetter(),
                              info: info,
                              propertyType: .finalFloat,
                              unitType: newUnitType,
                              float: defaultValue)
        newProperty.timeExponent = measureTime
        newProperty.unit = newUnit

        return newProperty
    }
}

enum FixedBorder: String, Codable, CaseIterable {

    case none
    case normal
    case opaque

    var description: String {
        switch self {
        case .none:
            return Texts.borderNone
        case .normal:
            return Texts.borderNormal
        case .opaque:
            return Texts.borderOpaque
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedNoise: String, Codable, CaseIterable {

    case none
    case gaussian
    case perlin

    var description: String {
        switch self {
        case .none:
            return Texts.noiseNone
        case .gaussian:
            return Texts.gaussian
        case .perlin:
            return Texts.perlin
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedContrast: String, Codable, CaseIterable {

    case uniform
    case gaussian
    case cosine

    var description: String {
        switch self {
        case .uniform:
            return Texts.contrastUniform
        case .gaussian:
            return Texts.contrastGaussian
        case .cosine:
            return Texts.contrastCosine
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedModulator: String, Codable, CaseIterable {

    case none
    case sinusoidal

    var description: String {
        switch self {
        case .none:
            return Texts.modulatorNone
        case .sinusoidal:
            return Texts.modulatorSinusoidal
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedOrigin2d: String, Codable, CaseIterable {

    case center = "center"
    case cartesian = "cartesian vars"
    case polar = "polar vars"

    var description: String {
        switch self {
        case .center:
            return Texts.origin2dCenter
        case .cartesian:
            return Texts.origin2dCartesian
        case .polar:
            return Texts.origin2dPolar
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedPosition2d: String, Codable, CaseIterable {

    case vector2d = "vector2d"
    case cartesian = "cartesian vars"
    case polar = "polar vars"

    var description: String {
        switch self {
        case .vector2d:
            return Texts.position2dVector
        case .cartesian:
            return Texts.position2dCartesian
        case .polar:
            return Texts.position2dPolar
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedSize2d: String, Codable, CaseIterable {

    case vector2d = "vector2d"
    case cartesian = "cartesian vars"
    case xy = "x=y"

    var description: String {
        switch self {
        case .vector2d:
            return Texts.size2dVector
        case .cartesian:
            return Texts.size2dCartesian
        case .xy:
            return Texts.size2dXy
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedColor: String, Codable, CaseIterable {

    case vector3d = "vector3d"
    case rgb = "RGB vars"
    case luminance = "luminance"

    var description: String {
        switch self {
        case .vector3d:
            return Texts.colorVector
        case .rgb:
            return Texts.colorRgb
        case .luminance:
            return Texts.colorLuminance
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedBehaviour: String, Codable, CaseIterable {

    case same
    case different

    var description: String {
        switch self {
        case .same:
            return Texts.same
        case .different:
            return Texts.different
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedDirection: String, Codable, CaseIterable {

    case random = "random"
    case fixed = "fixed"
    case center = "center"
    case outCenter = "away from the center"
    case clockwise = "clockwise"
    case counterclockwise = "counterclockwise"

    var description: String {
        switch self {
        case .random:
            return Texts.random
        case .fixed:
            return Texts.fixed
        case .center:
            return Texts.center
        case .outCenter:
            return Texts.outCenter
        case .clockwise:
            return Texts.clockwise
        case .counterclockwise:
            return Texts.counterclockwise
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedSoundType: String, Codable, CaseIterable {

    case pureTone = "pureTone"
    case whiteNoise = "whiteNoise"

    var description: String {
        switch self {
        case .pureTone:
            return Texts.pureTone
        case .whiteNoise:
            return Texts.whiteNoise
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum StimuliStyle: String, Codable, CaseIterable {

    case metalRegular
    case dots
    case image
    case nonMetal
}
