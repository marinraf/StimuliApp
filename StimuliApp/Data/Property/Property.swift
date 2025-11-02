//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Property: Codable {

    var id: String
    var name: String

    var listOrder: Int
    var somethingId: String

    var info: String
    var propertyType: PropertyType
    var unitType: UnitType
    var unit: Unit
    var timeUnit: Unit
    var timeDependency: TimeDependency
    var timeExponent: Int
    var onlyInfo: Bool
    var text: String
    var float: Float
    var float1: Float
    var float2: Float
    var fixedValues: [String]
    var selectedValue: Int
    var timeFunction: TimeFunctions

    var properties: [Property]

    //empty
    init() {
        self.id = UUID().uuidString
        self.name = ""

        self.listOrder = 0
        self.somethingId = ""

        self.info = ""
        self.propertyType = .finalFloat
        self.unitType = .decimal
        self.unit = .none
        self.timeUnit = .second
        self.timeDependency = .alwaysConstant
        self.timeExponent = 0
        self.onlyInfo = false
        self.text = ""
        self.float = 0
        self.float1 = 0
        self.float2 = 0
        self.fixedValues = []
        self.selectedValue = 0
        self.timeFunction = .linear

        self.properties = []
    }

    //string
    init(name: String, info: String, text: String) {
        self.name = name
        self.info = info
        self.propertyType = .string
        self.text = text

        self.id = UUID().uuidString
        self.listOrder = 0
        self.somethingId = ""
        self.unitType = .decimal
        self.unit = .none
        self.timeUnit = .second
        self.timeDependency = .alwaysConstant
        self.timeExponent = 0
        self.onlyInfo = false
        self.float = 0
        self.float1 = 0
        self.float2 = 0
        self.fixedValues = []
        self.selectedValue = 0
        self.timeFunction = .linear
        self.properties = []
    }

    //select
    init(name: String,
         info: String,
         propertyType: PropertyType,
         unitType: UnitType,
         fixedValues: [String],
         selectedValue: Int,
         float: Float = 0) {

        self.name = name
        self.info = info
        self.propertyType = propertyType
        self.unitType = unitType
        self.unit = unitType.possibleUnits[0]
        self.fixedValues = fixedValues
        self.selectedValue = selectedValue
        self.float = float

        self.id = UUID().uuidString
        self.listOrder = 0
        self.somethingId = ""
        self.timeUnit = .second
        self.timeDependency = .alwaysConstant
        self.timeExponent = 0
        self.onlyInfo = false
        self.text = ""
        self.float1 = 0
        self.float2 = 0
        self.timeFunction = .linear
        self.properties = []

        self.addProperties()
    }

    //simple float, doble or triple
    init(name: String,
         info: String,
         propertyType: PropertyType,
         unitType: UnitType,
         float: Float) {

        self.name = name
        self.info = info
        self.propertyType = propertyType
        self.unitType = unitType
        self.unit = unitType.possibleUnits[0]
        self.timeDependency = propertyType.timeDependencies[0]
        self.float = float
        self.float1 = float
        self.float2 = float

        self.id = UUID().uuidString
        self.listOrder = 0
        self.somethingId = ""
        self.timeUnit = .second
        self.timeExponent = 0
        self.onlyInfo = false
        self.text = ""
        self.fixedValues = []
        self.selectedValue = 0
        self.timeFunction = .linear
        self.properties = []
    }

    //copy
    init(from oldProperty: Property) {

        self.id = UUID().uuidString
        self.name = oldProperty.name
        self.listOrder = oldProperty.listOrder
        self.somethingId = oldProperty.somethingId

        self.info = oldProperty.info
        self.propertyType = oldProperty.propertyType
        self.unitType = oldProperty.unitType
        self.unit = oldProperty.unit
        self.timeUnit = oldProperty.timeUnit

        self.timeDependency = oldProperty.timeDependency
        self.timeExponent = oldProperty.timeExponent

        self.onlyInfo = oldProperty.onlyInfo

        self.text = oldProperty.text
        self.float = oldProperty.float
        self.float1 = oldProperty.float1
        self.float2 = oldProperty.float2
        self.fixedValues = oldProperty.fixedValues
        self.selectedValue = oldProperty.selectedValue
        self.timeFunction = oldProperty.timeFunction
        self.properties = []

        for property in oldProperty.properties {
            let newProperty = Property(from: property)
            self.properties.append(newProperty)
        }
    }

    var nameToShow: String {
        if somethingId == "" {
            return name
        } else if let section = Flow.shared.test.sections.first(where: { $0.id == somethingId }) {
            if FixedRandomness(rawValue: self.string) != nil {
                return "for section: " + section.name.string
            } else {
                return section.name.string
            }
        } else if let listOfValues = Flow.shared.test.listsOfValues.first(where: { $0.id == somethingId }) {
            return "for list: " + listOfValues.name.string
        } else if let object = Flow.shared.test.objects.first(where: { $0.id == somethingId }) {
            if name == "Value" {
                return object.name.string + "Value"
            } else {
                return object.name.string
            }
        } else if let variable = Flow.shared.test.allVariables.first(where: { $0.id == somethingId }) {
            return variable.name + name
        } else {
            return name
        }
    }

    var string: String {
        return express(as: unit, timeUnit: timeUnit)
    }

    var descriptiveString: String {
        switch propertyType {
        case .image:
            if let list = Flow.shared.test.listsOfValues.first(where: { $0.dimensions == 4}) {
                let selected = float.toInt
                if list.values.count >= selected {
                    return "image#\(selected): " + list.values[selected - 1].text
                } else {
                    return "image#\(selected): "
                }
            } else {
                return ""
            }
        case .text:
            if let list = Flow.shared.test.listsOfValues.first(where: { $0.dimensions == 5}) {
                let selected = float.toInt
                if list.values.count >= selected {
                    return "text#\(selected): " + list.values[selected - 1].text
                } else {
                    return "text#\(selected): "
                }
            } else {
                return ""
            }
        case .video:
            if let list = Flow.shared.test.listsOfValues.first(where: { $0.dimensions == 6}) {
                let selected = float.toInt
                if list.values.count >= selected {
                    return "video#\(selected): " + list.values[selected - 1].text
                } else {
                    return "video#\(selected): "
                }
            } else {
                return ""
            }
        case .audio:
            if let list = Flow.shared.test.listsOfValues.first(where: { $0.dimensions == 7}) {
                let selected = float.toInt
                if list.values.count >= selected {
                    return "audio#\(selected): " + list.values[selected - 1].text
                } else {
                    return "audio#\(selected): "
                }
            } else {
                return ""
            }
        default:
            return string
        }
    }

    var stringWithoutUnit: String {
        return expressWithoutUnit(as: unit, timeUnit: timeUnit)
    }

    var dimensions: Int {
        if propertyType == .dobleSize || propertyType == .doblePosition || propertyType == .trialAccuracy {
            return 2
        } else if propertyType == .triple {
            return 3
        } else if propertyType == .image {
            return 4
        } else if propertyType == .text {
            return 5
        } else if propertyType == .video {
            return 6
        } else if propertyType == .audio {
            return 7
        } else {
            return 1
        }
    }

    var object: Object? {
        return Flow.shared.test.objects.first(where: { $0.id == somethingId })
    }

    var section: Section? {
        return Flow.shared.test.sections.first(where: { $0.id == somethingId })
    }

    var listOfValues: ListOfValues? {
        return Flow.shared.test.listsOfValues.first(where: { $0.id == somethingId })
    }

    var variable: Variable? {
        return Flow.shared.test.allVariables.first(where: { $0.id == somethingId })
    }

    var scene: Scene? {
        return Flow.shared.test.scenes.first(where: { $0.id == somethingId })
    }

    var allProperties: [Property] {
        var propertiesToReturn: [Property] = []
        for property in properties {
            propertiesToReturn += addProperties(property: property)
        }
        return propertiesToReturn
    }

    func addProperties(property: Property) -> [Property] {
        var propertiesToReturn: [Property] = [property]
        for newProperty in property.properties {
            propertiesToReturn += addProperties(property: newProperty)
        }
        return propertiesToReturn
    }

    var unitName: String {
        return getUnitName(unit: unit, timeUnit: timeUnit)
    }

    private func getUnitName(unit: Unit, timeUnit: Unit) -> String {
        let unitString = unit.name != "" ? " (\(unit.name))" : ""

        switch propertyType {
        case .string, .key, .select, .type, .shape, .border, .contrast, .noise, .modulator, .response, .sceneDuration,
                .position2d, .size2d, .positionResponse, .sceneGazeFixation, .sceneDistanceFixation, .origin2d, .originResponse,
                .value, .valueType, .distanceResponse, .correct, .correct2, .color, .objectResponse, .objectResponse2,
                .keyResponse, .randomness, .listOrder, .selection, .selectionDifferent, .distance, .selectionOrder,
                .correctType, .image, .text, .video, .audio, .font, .gamma, .behaviour, .direction, .soundType,
                .endPathResponse, .trialAccuracy, .testEyeTracker, .originEyeTracker, .positionEyeTracker, .language:
            return ""
        case .dobleSize, .doblePosition, .triple, .sequence:
            switch self.timeDependency {
            case .variable:
                return unitString
            default:
                return unit.si
            }
        case .timeFloat, .simpleFloat, .simpleFloatText, .finalFloat:
            switch self.timeDependency {
            case .variable:
                let unitToShow = si(unit, timeUnit)
                if unitToShow == "" {
                    return ""
                } else {
                    return "(\(unitToShow))"
                }
            default:
                return si(unit, timeUnit)
            }
        }
    }

    func express(as unit: Unit, timeUnit: Unit = .second) -> String {

        let name = getUnitName(unit: unit, timeUnit: timeUnit)

        if name == "" {
            return expressWithoutUnit(as: unit, timeUnit: timeUnit)
        } else {
            return expressWithoutUnit(as: unit, timeUnit: timeUnit) + " " + name
        }
    }

    func expressWithoutUnit(as unit: Unit, timeUnit: Unit = .second) -> String {
        let values = self.separated(as: unit, timeUnit: timeUnit)

        switch propertyType {
        case .image, .text, .video, .audio:
            switch self.timeDependency {
            case .variable:
                return "variable"
            default:
                return values[0]
            }
        case .string, .key, .font:
            return text
        case .select, .type, .shape, .border, .contrast, .noise, .modulator, .response, .size2d, .distanceResponse,
                .position2d, .positionResponse, .sceneGazeFixation, .sceneDistanceFixation, .origin2d, .originResponse,
                .value, .valueType, .correct, .correct2, .correctType, .sceneDuration, .color, .objectResponse,
                .objectResponse2, .keyResponse, .randomness, .listOrder, .endPathResponse, .selection, .selectionDifferent,
                .selectionOrder, .gamma, .behaviour, .direction, .soundType, .distance,
                .testEyeTracker, .originEyeTracker, .positionEyeTracker, .language:
            return fixedValues[selectedValue]
        case .dobleSize:
            switch self.timeDependency {
            case .variable:
                return "variable"
            default:
                return values[0] + "x" + values[1]
            }
        case .doblePosition, .trialAccuracy:
            switch self.timeDependency {
            case .variable:
                return "variable"
            default:
                return values[0] + ";" + values[1]
            }
        case .triple, .sequence:
            switch self.timeDependency {
            case .variable:
                return "variable"
            default:
                return values[0] + ";" + values[1] + ";" + values[2]
            }
        case .timeFloat, .simpleFloat, .simpleFloatText, .finalFloat:
            switch self.timeDependency {
            case .alwaysConstant, .constant:
                return values[0]
            case .variable:
                return "variable"
            case .timeDependent:
                return timeFunction.name
            }
        }
    }

    func expressSeparatedWithoutUnit(as unit: Unit, timeUnit: Unit) -> [String] {
        let values = self.separated(as: unit, timeUnit: timeUnit)

        switch propertyType {
        case .image, .text, .video, .audio:
            return [values[0], values[1], values[2]]
        case .string, .key, .font:
            return [text, "", ""]
        case .select, .type, .shape, .border, .contrast, .noise, .modulator, .response, .sceneDuration,
             .position2d, .positionResponse, .sceneGazeFixation, .sceneDistanceFixation, .origin2d, .originResponse,
             .size2d, .value, .valueType, .distanceResponse, .correct, .correct2, .correctType, .color,
             .objectResponse, .objectResponse2, .keyResponse, .randomness, .listOrder, .selection, .distance,
             .selectionDifferent, .selectionOrder, .gamma, .behaviour, .direction, .soundType, .endPathResponse,
             .testEyeTracker, .originEyeTracker, .positionEyeTracker, .language:
            return [fixedValues[selectedValue], "", ""]
        case .dobleSize, .doblePosition, .trialAccuracy:
            return [values[0], values[1], ""]
        case .triple, .sequence:
            return [values[0], values[1], values[2]]
        case .timeFloat, .simpleFloat, .simpleFloatText, .finalFloat:
            return [values[0], "", ""]
        }
    }

    func separated(as unit: Unit, timeUnit: Unit) -> [String] {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.maximumFractionDigits = Constants.maxFractionDigits

        var newNewFloat = fromUnitToNewUnit(value: float,
                                            unit: unitType.referenceUnit,
                                            newUnit: unit,
                                            timeUnit: .second,
                                            newTimeUnit: timeUnit)

        let newNewFloat1 = fromUnitToNewUnit(value: float1,
                                             unit: unitType.referenceUnit,
                                             newUnit: unit,
                                             timeUnit: .second,
                                             newTimeUnit: timeUnit)

        let newNewFloat2 = fromUnitToNewUnit(value: float2,
                                             unit: unitType.referenceUnit,
                                             newUnit: unit,
                                             timeUnit: .second,
                                             newTimeUnit: timeUnit)

        switch propertyType {
        case .image, .text, .video, .audio:
            return [String(float.toInt), "", ""]
        case .string, .key, .font:
            return [text]
        case .select, .type, .shape, .border, .contrast, .modulator, .response, .sceneDuration, .distanceResponse,
             .correctType, .correct, .correct2, .position2d, .size2d, .positionResponse, .sceneGazeFixation, .sceneDistanceFixation,
             .origin2d, .originResponse, .value, .valueType, .noise, .color, .objectResponse, .objectResponse2, .keyResponse,
             .randomness, .listOrder, .endPathResponse, .selection, .selectionDifferent, .selectionOrder, .gamma, .behaviour,
             .direction, .soundType, .distance, .testEyeTracker, .originEyeTracker, .positionEyeTracker, .language:
            return [fixedValues[selectedValue]]
        case .dobleSize, .doblePosition, .trialAccuracy:
            let value = numberFormatter.string(from: newNewFloat as NSNumber) ?? ""
            let value2 = numberFormatter.string(from: newNewFloat1 as NSNumber) ?? ""
            return [value, value2]
        case .triple, .sequence:
            let value = numberFormatter.string(from: newNewFloat as NSNumber) ?? ""
            let value2 = numberFormatter.string(from: newNewFloat1 as NSNumber) ?? ""
            let value3 = numberFormatter.string(from: newNewFloat2 as NSNumber) ?? ""
            return [value, value2, value3]
        case .timeFloat, .simpleFloat, .simpleFloatText, .finalFloat:
            if timeUnit == .frame && unit == .none && timeExponent == 1 {
                newNewFloat = roundf(newNewFloat)
            }
            let value = numberFormatter.string(from: newNewFloat as NSNumber) ?? ""
            return [value]
        }
    }

    private func fromUnitToNewUnit(values: [Float],
                                   unit: Unit,
                                   newUnit: Unit,
                                   timeUnit: Unit,
                                   newTimeUnit: Unit) -> [Float] {

        var newValues: [Float] = []
        for element in values {
            let newValue = fromUnitToNewUnit(value: element,
                                             unit: unit,
                                             newUnit: newUnit,
                                             timeUnit: timeUnit,
                                             newTimeUnit: newTimeUnit)
            newValues.append(newValue)
        }
        return newValues
    }

    private func fromUnitToNewUnit(value: Float,
                                   unit: Unit,
                                   newUnit: Unit,
                                   timeUnit: Unit,
                                   newTimeUnit: Unit) -> Float {

        let factor1 = unit.factor
        let factor2 = newUnit.factor

        let timeFactor1 = timeUnit.factor
        let timeFactor2 = newTimeUnit.factor

        let factor = factor1 / factor2

        var timeFactor = timeFactor1 / timeFactor2

        if timeExponent == 0 {
            timeFactor = 1
        } else if timeExponent == 1 {
            timeFactor = timeFactor1 / timeFactor2
        } else if timeExponent == -1 {
            timeFactor = timeFactor2 / timeFactor1
        } else {
            timeFactor = powf((timeFactor1 / timeFactor2), Float(timeExponent))
        }

        return value * factor * timeFactor
    }

    func changeValue(new floats: [Float]) {

        let newFloats = fromUnitToNewUnit(values: floats,
                                          unit: unit,
                                          newUnit: unitType.referenceUnit,
                                          timeUnit: timeUnit,
                                          newTimeUnit: .second)
        var second = false
        if unitType == .twoValues {
            second = true
        }

        if newFloats.count > 0 {
            self.float = unitType.delimit(float: newFloats[0], second: false)
        }
        if newFloats.count > 1 {
            self.float1 = unitType.delimit(float: newFloats[1], second: second)
        }
        if newFloats.count > 2 {
            self.float2 = unitType.delimit(float: newFloats[2], second: false)
        }
    }

    func changeValue(new float: Float) {

        let newFloats = fromUnitToNewUnit(values: [float],
                                          unit: unit,
                                          newUnit: unitType.referenceUnit,
                                          timeUnit: timeUnit,
                                          newTimeUnit: .second)

        if newFloats.count > 0 {
            self.float = unitType.delimit(float: newFloats[0], second: false)
        }
    }

    func changeTimeUnit(new timeUnit: Unit) {
        self.timeUnit = timeUnit
    }

    func changeSelectedValue(new selectedValue: Int, propertyType: PropertyType) {

        for object in Flow.shared.test.objects where object.stimulus === Flow.shared.stimulus {

            for variable in object.variables where allProperties.contains(where: { $0 === variable.property }) {
                Flow.shared.deleteVariable(variable)
            }
        }

        self.selectedValue = selectedValue
        switch propertyType {
        case .type:
            if let stimulusType = StimuliType(rawValue: self.string) {
                
                Flow.shared.stimulus.typeProperty.fixedValues = StimuliType.allCases.map({ $0.name })
                
                if stimulusType == .text || stimulusType == .video ||
                    stimulusType == .audio || stimulusType == .pureTone {
                    
                    
                    Flow.shared.stimulus.shapeProperty = StimulusData.makeShapeProperty(shape: .rectangle)
                    Flow.shared.stimulus.originProperty = StimulusData.makeOriginProperty(selected: 0)
                    Flow.shared.stimulus.positionProperty = StimulusData.makePositionProperty(selected: 0)
                    Flow.shared.stimulus.rotationProperty = StimulusData.makeRotationProperty(float: 0)
                    Flow.shared.stimulus.borderProperty = StimulusData.makeBorderProperty(selected: 0)
                    Flow.shared.stimulus.contrastProperty = StimulusData.makeContrastProperty(selected: 0)
                    Flow.shared.stimulus.modulatorProperty = StimulusData.makeModulatorProperty(selected: 0)
                    Flow.shared.stimulus.noiseProperty = StimulusData.makeNoiseProperty(selected: 0)
                }
                for object in Flow.shared.test.objects where object.stimulusId == Flow.shared.stimulus.id {

                    if let scene = object.scene {
                        Flow.shared.deleteObject(object)
                        _ = Flow.shared.createSaveAndSelectNewObject(from: Flow.shared.stimulus, scene: scene)
                    }
                }
            }
        default:
            if FixedSelection(rawValue: self.string) != nil {
                if let group = Int(self.somethingId) {
                    let variables = Flow.shared.section.allVariables.filter({ $0.group == group && group != 0 })
                    for variable in variables {
                        variable.selection.selectedValue = selectedValue
                        variable.selection.addProperties()
                    }
                }
                if Flow.shared.section.isShuffled {
                    if Flow.shared.test.randomness.selectedValue != 0 &&
                        !Flow.shared.test.randomness.properties.contains(where: { $0.name == Flow.shared.section.id }) {
                        let newProperty = TestData.makePropertyToAddToRandomness(name: Flow.shared.section.id)
                        Flow.shared.test.randomness.properties.append(newProperty)
                    }
                } else {
                    Flow.shared.test.randomness.properties = Flow.shared.test.randomness.properties.filter({
                        $0.name != Flow.shared.section.id
                    })
                }
            } else if FixedListOrder(rawValue: self.string) != nil {
                if Flow.shared.listOfValues.isShuffled || Flow.shared.listOfValues.isRandomBlock {
                    if Flow.shared.test.randomness.selectedValue != 0 &&
                        !Flow.shared.test.randomness.properties.contains(where: {
                            $0.name == Flow.shared.listOfValues.id }) {
                        let newProperty = TestData.makePropertyToAddToRandomness(name: Flow.shared.listOfValues.id)
                        Flow.shared.test.randomness.properties.append(newProperty)
                    }
                } else {
                    Flow.shared.test.randomness.properties = Flow.shared.test.randomness.properties.filter({
                        $0.name != Flow.shared.listOfValues.id
                    })
                }
            } else if FixedSelectionDifferent(rawValue: self.string) != nil {
                for variable in Flow.shared.section.allVariables where variable.group == Flow.shared.group
                    && variable.group != 0 {
                        variable.selection.properties[0].selectedValue = selectedValue
                }
            } else if FixedSelectionPriority(rawValue: self.string) != nil {
                for variable in Flow.shared.section.allVariables where variable.group == Flow.shared.group
                    && variable.group != 0 {
                        variable.selection.properties[0].selectedValue = selectedValue
                }
            } else if FixedResponse(rawValue: self.string) != nil {
                Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            } else if FixedCartesianDistances(rawValue: self.string) != nil {
                Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            } else if FixedPolarDistances(rawValue: self.string) != nil {
                Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            } else if FixedPositionResponse(rawValue: self.string) != nil {
                Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            } else if let correct = FixedCorrectType(rawValue: self.string) {
                for variable in Flow.shared.section.allVariables where variable.selection.properties.count > 0 {
                    if variable.selection.properties[0] === self {
                        let vars = variable.allVariablesInSameGroup(section: Flow.shared.section)
                        for item in vars {
                            VariableData.addPropertiesToSelection(property: item.selection, correct: correct)
                        }
                    }
                }
            }
        }

        if Flow.shared.scene.objects.count > 0 {
            let otherObject = Flow.shared.scene.objects[0]

            for variable in otherObject.variables where allProperties.contains(where: { $0 === variable.property }) {
                Flow.shared.deleteVariable(variable)
            }
            if Flow.shared.scene.color.allProperties.contains(where: { $0.id == self.id }) {
                if timeDependency == .variable {
                    otherObject.addVariable(from: self)
                }
            }
        }
        self.addProperties()
    }

    func changeTimeDependency(new timeDependency: TimeDependency, timeFunction: TimeFunctions) {

        self.timeFunction = timeFunction
        self.timeDependency = timeDependency

        let properties = [self] + self.properties

        var isColorScene = false
        for scene in Flow.shared.test.scenes {
            if scene.color.allProperties.contains(where: { $0.id == self.id }) {
                isColorScene = true
            }
        }

        if !isColorScene {
            for object in Flow.shared.test.objects where object.stimulus === Flow.shared.stimulus {

                for variable in object.variables where properties.contains(where: { $0 === variable.property }) {
                    Flow.shared.deleteVariable(variable)
                }

                if timeDependency == .variable {
                    object.addVariable(from: self)
                }
            }
        }

        if Flow.shared.scene.objects.count > 0 {
            let otherObject = Flow.shared.scene.objects[0]

            for variable in otherObject.variables where properties.contains(where: { $0 === variable.property }) {
                Flow.shared.deleteVariable(variable)
            }
            if Flow.shared.scene.color.allProperties.contains(where: { $0.id == self.id }) {
                if timeDependency == .variable {
                    otherObject.addVariable(from: self)
                }
            }
        }
        self.addProperties()
    }

    func changeUnit(new unit: Unit) {

        for element in properties where element.unit == self.unit {
            element.unit = unit
        }
        self.unit = unit
    }

    func si(_ unit: Unit, _ timeUnit: Unit) -> String {
        let exp = abs(timeExponent)
        let expString = exp == 1 ? "" : exp.exponentiate()

        if unit == .cdm2 {
            if Flow.shared.settings.maximumBrightness > 10 {
                let value = self.float * Flow.shared.settings.maximumBrightness
                return " (\(value) cd/m²)"
            } else {
                return ""
            }
        } else if name.hasSuffix("Luminance") && timeExponent == 0 && properties.isEmpty
            && timeDependency != .variable && name != "maximumLuminance" {
            if Flow.shared.settings.maximumBrightness > 10 {

                var value = self.float * Flow.shared.settings.maximumBrightness

                if Flow.shared.settings.device.type != .mac  {
                    value *=  Flow.shared.test.brightness.float
                }
                return " (\(value) cd/m²)"
            } else {
                return ""
            }
        } else if unit == .none {
            if timeExponent == 0 {
                return ""
            } else if timeExponent < 0 {
                return timeUnit.si + "\u{207B}" + exp.exponentiate()
            } else {
                return timeUnit.si + expString
            }
        } else {
            if timeExponent == 0 {
                return unit.si
            } else if timeExponent < 0 {
                return unit.si + "/" + timeUnit.si + expString
            } else {
                return unit.si + "·" + timeUnit.si + expString
            }
        }
    }

    private func filterVariables(object: Object, propertiesToDelete: [Property]) {
        for element in propertiesToDelete {
            object.variables = object.variables.filter({ $0.property !== element })
            filterVariables(object: object, propertiesToDelete: element.properties)
        }
    }

    func addProperties() {
        
        if propertyType == .language {
            return
        }

        for object in Flow.shared.test.objects where object.stimulus === Flow.shared.stimulus {
            let properties = self.properties
            filterVariables(object: object, propertiesToDelete: properties)
        }

        if Flow.shared.scene.objects.count > 0 {
            let otherObject = Flow.shared.scene.objects[0]
            filterVariables(object: otherObject, propertiesToDelete: properties)
        }

        switch propertyType {
        case .size2d:
            StimulusData.addPropertiesToSize2d(property: self)
        case .position2d:
            StimulusData.addPropertiesToPosition2d(property: self)
        case .origin2d:
            StimulusData.addPropertiesToOrigin2d(property: self)
        case .color:
            StimulusData.addPropertiesToColor(property: self)
        case .type:
            StimulusData.addPropertiesToType(property: self)
        case .shape:
            StimulusData.addPropertiesToShape(property: self)
        case .border:
            StimulusData.addPropertiesToBorder(property: self)
        case .noise:
            StimulusData.addPropertiesToNoise(property: self)
        case .contrast:
            StimulusData.addPropertiesToContrast(property: self)
        case .modulator:
            StimulusData.addPropertiesToModulator(property: self)
        case .timeFloat:
            StimulusData.addPropertiesToTimeFunction(property: self)
        case .direction:
            StimulusData.addPropertiesToDirection(property: self)
        case .soundType:
            StimulusData.addPropertiesToSoundType(property: self)
        case .response:
            SceneData.addPropertiesToResponse(property: self)
        case .sceneDuration:
            SceneData.addPropertiesToSceneDuration(property: self)
        case .positionResponse:
            SceneData.addPropertiesToPositionResponse(property: self)
        case .distanceResponse:
            SceneData.addPropertiesToDistanceResponse(property: self)
        case .endPathResponse:
            SceneData.addPropertiesToEndPathResponse(property: self)
        case .originResponse:
            SceneData.addPropertiesToOriginResponse(property: self)
        case .objectResponse:
            SceneData.addPropertiesToObjectResponse(property: self)
        case .objectResponse2:
            SceneData.addPropertiesToObjectResponse2(property: self)
        case .keyResponse:
            SceneData.addPropertiesToKeyResponse(property: self)
        case .distance:
            TestData.addPropertiesToDistance(property: self)
        case .randomness:
            TestData.addPropertiesToRandomness(property: self)
        case .selection:
            VariableData.addPropertiesToSelection(property: self)
        case .value:
            SectionData.addPropertiesToValue(property: self)
        case .valueType:
            SectionData.addPropertiesToValueType(property: self)
        case .correct:
            SectionData.addPropertiesToCorrect(property: self)
        case .correct2:
            SectionData.addPropertiesToCorrect2(property: self)
        case .gamma:
            TestData.addPropertiesToGamma(property: self)
        case .sceneGazeFixation:
            SceneData.addPropertiesToSceneGazeFixation(property: self)
        case .sceneDistanceFixation:
            SceneData.addPropertiesToSceneDistanceFixation(property: self)
        case .testEyeTracker:
            TestData.addPropertiesToEyeTracker(property: self)
        case .positionEyeTracker:
            TestData.addPropertiesToPositionEyeTracker(property: self)
        case .simpleFloat, .simpleFloatText, .string, .key, .select, .dobleSize, .doblePosition, .triple, .sequence,
             .finalFloat, .listOrder, .selectionDifferent, .selectionOrder, .correctType,
             .image, .text, .video, .audio, .font, .behaviour, .trialAccuracy, .originEyeTracker, .language:
            break
        }
    }
}

