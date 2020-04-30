//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Modify: Screen {

    enum ResponseStyle {
        case used
        case invalid
        case saved
        case again
        case seed
    }

    var style: ScreenStyle = .modify
    var title: String = ""
    var info0: String = ""
    var info: String = ""
    var extraInfo: String = ""
    var numberKeyboard: Bool = true
    var badNames: [String] = []
    var property: Property = Property()
    var multipleValues: Bool = false
    var alertTitle: String = "The name is already in use"
    var alertMessage: String = "Please provide a different name."
    var placeholders: [String] = ["", "", ""]
    var propertyType: PropertyType = .simpleFloat
    var unitType: UnitType = .decimal
    var unit: Unit = .none
    var timeUnit: Unit = .second
    var timeExponent: Int = 0
    var timeDependency: TimeDependency = .alwaysConstant
    var timeFunction: TimeFunctions = .linear
    var float0: Float = 0
    var float1: Float = 0
    var float2: Float = 0
    var selectedValue: Int = 0
    var saveFunctionString: (String) -> (ResponseStyle) = { response in return ResponseStyle.saved }
    var saveFunctionFloats: ([Float]) -> (ResponseStyle) = { response in return ResponseStyle.saved }
    var saveFunctionSelect: () -> (ResponseStyle) = { return ResponseStyle.saved }
    var isSeed: Bool = false

    init(title: String,
         info: String,
         badNames: [String] = [],
         property: Property) {

        self.title = title
        self.info0 = info
        self.info = info
        self.badNames = badNames
        self.property = property
        self.propertyType = property.propertyType
        self.numberKeyboard = propertyType.numberKeyboard
        self.unitType = property.unitType
        self.unit = property.unit
        self.timeUnit = property.timeUnit
        self.timeExponent = property.timeExponent
        self.timeDependency = property.timeDependency
        self.timeFunction = property.timeFunction
        self.float0 = property.float
        self.float1 = property.float1
        self.float2 = property.float2
        self.selectedValue = property.selectedValue

        settingInfo()
    }

    init() { }

    func settingInfo() {
        info = info0 + "\n\n" + unit.info
        if timeDependency == .timeDependent {
            extraInfo = timeFunction.description
        } else if propertyType == .type {
            info = ""
            extraInfo = StimuliType.allCases[selectedValue].description
        } else if propertyType == .response {
            info = ""
            extraInfo = FixedResponse.allCases[selectedValue].description
        } else {
            extraInfo = ""
        }
    }

    func settingPlaceholders() {
        let values = property.separated(as: unit, timeUnit: timeUnit)
        if let value0 = Float(values[0]) {
            float0 = value0
        }
        if values.count > 1 {
            if let value1 = Float(values[1]) {
                float1 = value1
            }
        }
        if values.count > 2 {
            if let value2 = Float(values[2]) {
                float2 = value2
            }
        }
        placeholders[0] = property.expressSeparatedWithoutUnit(as: unit, timeUnit: timeUnit)[0]
        placeholders[1] = property.expressSeparatedWithoutUnit(as: unit, timeUnit: timeUnit)[1]
        placeholders[2] = property.expressSeparatedWithoutUnit(as: unit, timeUnit: timeUnit)[2]
    }

    func save(responses: [String]) -> ResponseStyle {

        if property.unit != unit {
            property.changeUnit(new: unit)
        }

        if property.timeUnit != timeUnit {
            property.changeTimeUnit(new: timeUnit)
        }

        if property.propertyType == .type || property.propertyType == .response {
            property.changeSelectedValue(new: selectedValue, propertyType: property.propertyType)
        }

        if property.timeDependency != timeDependency || property.timeFunction != timeFunction {
            if timeDependency == .constant {
                timeFunction = .linear
            }
            property.changeTimeDependency(new: timeDependency, timeFunction: timeFunction)
        }

        if property.timeDependency == .variable || property.timeDependency == .timeDependent {
            return saveFunctionSelect()
        } else if responses[0] == "" || responses[1] == "" || responses[2] == "" {
            return saveFunctionSelect()
        } else if badNames.contains(responses[0]) {
            return .used
        } else if property.unitType == .variableUnit && property.propertyType != .sequence
            && property.propertyType != .doblePosition && property.propertyType != .triple && property.name == "" {
            return saveFunctionString(responses[0])
        } else if numberKeyboard {
            if let float0 = Float(responses[0]), let float1 = Float(responses[1]), let float2 = Float(responses[2]) {
                return saveFunctionFloats([float0, float1, float2])
            } else {
                return .invalid
            }
        } else if responses == ["0.0", "0.0", "0.0"] {
            Flow.shared.saveTest(Flow.shared.test)
            return .saved
        } else {
            return saveFunctionString(responses[0])
        }
    }
}
