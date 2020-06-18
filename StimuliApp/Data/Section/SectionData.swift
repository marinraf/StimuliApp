//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct SectionData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: "A name to identify this section.",
                        text: text)
    }

    static func makeRepetitionsProperty(float: Float) -> Property {

        let property = Property(name: "repetitions",
                                info: Texts.repetitions,
                                propertyType: .simpleFloat,
                                unitType: .positiveIntegerWithoutZero,
                                float: float)
        return property
    }

    static func makeTrialValueProperty(float: Float) -> Property {
        return Property(name: "trialValue",
                        info: "",
                        propertyType: .value,
                        unitType: .decimal,
                        float: float)
    }

    static func makeResponseValueProperty(selected: Int) -> Property {
        return Property(name: "responseValue",
                        info: "",
                        propertyType: .correct,
                        unitType: .decimal,
                        fixedValues: FixedCorrect.allCases.map { $0.name },
                        selectedValue: selected)
    }

    static func makeNextProperty() -> Property {
        return Property(name: "when all the section trials have been performed",
                        info: Texts.allTrials,
                        text: "End the test")
    }

    static func addPropertiesToValue(property: Property) {

        property.properties = []

        if let variable = property.variable {
            let newProperty = Property(name: "Value",
                info: "",
                propertyType: .valueType,
                unitType: .decimal,
                fixedValues: FixedValueType.allCases.map({ $0.name }),
                selectedValue: 0)
            newProperty.somethingId = variable.id
            property.properties.append(newProperty)
        }
    }

    static func addPropertiesToValueType(property: Property) {

        property.properties = []

        guard let valueType = FixedValueType(rawValue: property.string) else { return }
        guard valueType == .other else { return }

        if let variable = property.variable, let list = variable.listOfValues {

            if list.dimensions == 8 {

                for value in list.allValuesBlock {
                    let newProperty = Property(name: "when \(variable.name) = \(value.string)",
                        info: "",
                        propertyType: .simpleFloat,
                        unitType: .responseUnit,
                        float: 0)
                    property.properties.append(newProperty)
                }

            } else {
                for value in list.values {
                    let newProperty = Property(name: "when \(variable.name) = \(value.string)",
                        info: "",
                        propertyType: .simpleFloat,
                        unitType: .responseUnit,
                        float: 0)
                    property.properties.append(newProperty)
                }
            }
        }
    }

    static func addPropertiesToValueTypeWithDict(property: Property, oldKeys: [String]) {

        let values = property.properties.map({ $0.float })

        property.properties = []

        guard let valueType = FixedValueType(rawValue: property.string) else { return }
        guard valueType == .other else { return }
        guard let variable = property.variable else { return }
        guard let list = variable.listOfValues else { return }
        guard list.dimensions == 8 else { return }

        let myDict = Dictionary(uniqueKeysWithValues: zip(oldKeys, values))

        for value in list.allValuesBlock {
            let newProperty = Property(name: "when \(variable.name) = \(value.string)",
                info: "",
                propertyType: .simpleFloat,
                unitType: .responseUnit,
                float: 0)
            if let newFloat = myDict[value.id] {
                newProperty.float = newFloat
            }
            property.properties.append(newProperty)
        }
    }

    static func addPropertiesToCorrect(property: Property) {

        property.properties = []

        let newProperty = Property(name: "marginError",
                                   info: Texts.marginError,
                                   propertyType: .simpleFloat,
                                   unitType: .variableUnit,
                                   float: 0.01)
        if property.somethingId != "" {
            property.properties.append(newProperty)
        }
    }

    static func changeValueNames(property: Property, list: ListOfValues) {

        guard let same = FixedValueType(rawValue: property.string) else { return }
        switch same {
        case .same:
            property.properties = []
        case .other:
            if let variable = property.variable {
                for i in 0 ..< list.values.count {
                    property.properties[i].name = "when \(variable.name) = \(list.values[i].string)"
                }
            }
        }
    }
}

//do not change the names without checking the comment fixedNames
enum FixedValueType: String, Codable, CaseIterable {

    case same
    case other

    var description: String {
        switch self {
        case .same:
            return """
            In each of the trials the variable has a value that is one of the possible values of a list of
            values plus a jittering value. This is the value associated to each trial.
            """
        case .other:
            return """
            For each one of the possible values of the variable, we can define a corresponding value for the trial.
            At first the value we define is a numeric value without any unit. If we define a response value \
            for the interaction of the participant, then the value we define here as value for the trial \
            will be considered to have the same unit as the unit we are using as response.
            Example: if we have fixed the response of the user as the x position of the touch in the screen, \
            measured in cms, and we fix here the trial values to be: 5, 10, then these values willl be treated \
            as 5cm and 10cm in order to do the comparisons with the response.
            """
        }
    }

    var name: String {
        return rawValue
    }
}

enum FixedCondition: String, Codable, CaseIterable {

    case numberOfTrials = "when the number of trials = n"
    case numberOfResponses = "when the number of trials responded in time = n"
    case numberOfNotResponses = "when the number of trials not responded in time = n"
    case numberCorrects = "when the number of correct trials = n"
    case numberIncorrects = "when the number of incorrect trials = n"
    case lastResponded = "when the last trial was responded in time"
    case lastNotResponded = "when the last trial was not responded in time"
    case lastCorrect = "when the last trial was correct"
    case lastIncorrect = "when the last trial was incorrect"

    var description: String {
       return self.rawValue
    }

    var name: String {
        return self.rawValue
    }

    func name(n: Int) -> String {
        if name.last == "n" {
            return String(name.dropLast()) + String(n)
        } else {
            return name
        }
    }
}
