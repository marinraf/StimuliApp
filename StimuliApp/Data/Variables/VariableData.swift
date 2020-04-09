//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct VariableData {

    static func makeObjectProperty(text: String) -> Property {

        let property = Property(name: "object",
                                info: "Object name.",
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeStimulusProperty(text: String) -> Property {

        let property = Property(name: "stimulus",
                                info: "Stimulus name.",
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makePropertyProperty(text: String) -> Property {

        let property = Property(name: "property",
                                info: "Property name.",
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeSelectionProperty(selected: Int) -> Property {
        let property = Property(name: "selectionMethod",
                                info: """
                                The different methods used for the variables to take their values from their list.
                                """,
                                propertyType: .selection,
                                unitType: .decimal,
                                fixedValues: FixedSelection.allCases.map { $0.name },
                                selectedValue: 0)
        property.somethingId = String(0)
        return property
    }

    static func addPropertiesToSelection(property: Property) {
        property.properties = []

        let correctType = Property(name: property.name + "Correct",
                                   info: """
                                   How the correct response determines the value of this variable.
                                   """,
                                   propertyType: .correctType,
                                   unitType: .decimal,
                                   fixedValues: FixedCorrectType.allCases.map { $0.name },
                                   selectedValue: 0)

        let priority = Property(name: property.name + "Priority",
                             info: """
                             The priority of the method.

                             For example:

                             First variable gets its values in order and its possible values are: 0, 1.

                             Second variable gets its values in order too and its possible values are: 10, 20, 30.

                             Depending which variable has a higher priority the result can be:

                             0,10
                             0,20
                             0,30
                             1,10
                             1,20
                             1,30

                             if the first variable has higher priority, or:

                             0,10
                             1,10
                             0,20
                             1,20
                             0,30
                             1,30

                             if the second variable has higher priority.
                             """,
                             propertyType: .selectionOrder,
                             unitType: .decimal,
                             fixedValues: FixedSelectionPriority.allCases.map { $0.name },
                             selectedValue: 0)

        let equal = Property(name: property.name + "Equal",
                             info: """
                             Whether or not the selection of values ​​for all the related variables is the same.
                             """,
                             propertyType: .selectionDifferent,
                             unitType: .decimal,
                             fixedValues: FixedSelectionDifferent.allCases.map { $0.name },
                             selectedValue: 0)

        guard let selected = FixedSelection(rawValue: property.string) else { return }
        let group = Int(property.somethingId) ?? 0
        switch selected {
        case .correct:
            property.properties.append(correctType)
        case .inOrder:
            property.properties.append(priority)
        case .shuffled:
            break
        case .fixed:
            if group != 0 {
                for variable in Flow.shared.section.variables where variable.group == Int(property.somethingId) {
                    property.properties.append(makePropertyToAddToSelection(variable: variable))
                }
            } else {
                for variable in Flow.shared.section.variables where variable.selection === property {
                    property.properties.append(makePropertyToAddToSelection(variable: variable))
                }
            }
        case .random:
            if group != 0 {
                property.properties.append(equal)
            }
        }
    }

    static func addPropertiesToSelection(property: Property, correct: FixedCorrectType) {
        property.properties = [property.properties[0]]
        let selectedValue = FixedCorrectType.allCases.firstIndex(of: correct) ?? 0
        property.properties[0].selectedValue = selectedValue

        if correct != .zero {
            let group = Int(property.somethingId) ?? 0
            if group != 0 {
                for variable in Flow.shared.section.variables where variable.group == Int(property.somethingId) {
                    property.properties.append(makePropertyToAddToSelection2(variable: variable))
                }
            } else {
                for variable in Flow.shared.section.variables where variable.selection === property {
                    property.properties.append(makePropertyToAddToSelection2(variable: variable))
                }
            }
        }
    }

    static func makePropertyToAddToSelection(variable: Variable) -> Property {
        let newProperty = Property(name: "Value",
                                   info: """
                                   Select one of the values from the list. From 1 to the total number of values.
                                   """,
                                   propertyType: .simpleFloat,
                                   unitType: .positiveIntegerWithoutZero,
                                   float: 1)
        newProperty.somethingId = variable.id
        return newProperty
    }

    static func makePropertyToAddToSelection2(variable: Variable) -> Property {
        let newProperty = Property(name: "InitialValue",
                                   info: """
                                   Select one of the values from the list.
                                   From 1 to the total number of values. This will be the first value.
                                   From there, the value will change following the chosen formula.
                                   """,
                                   propertyType: .simpleFloat,
                                   unitType: .positiveIntegerWithoutZero,
                                   float: 1)
        newProperty.somethingId = variable.id
        return newProperty
    }
}

//do not change the names without checking the comment fixedNames
enum FixedSelection: String, Codable, CaseIterable {

    case inOrder = "all values in order"
    case shuffled = "all values in random order"
    case fixed = "one fixed value"
    case random = "one random value"
    case correct = "depends on correct"

    var description: String {
        switch self {
        case .inOrder:
            return "The variable gets all the values from the list in order."
        case .shuffled:
            return "The variable gets all the values from the list in random order."
        case .fixed:
            return "The variable value is always the same fixed value from the list."
        case .random:
            return "In each trial, the variable value is a random value from the list."
        case .correct:
            return "The variable value depends on the correction of the previous response."
        }
    }

    var name: String {
        return self.rawValue
    }
}

//do not change the names without checking the comment fixedNames
enum FixedSelectionDifferent: String, Codable, CaseIterable {

    case equal
    case different

    var description: String {
        switch self {
        case .equal:
            return """
            All the related variables take a value that is in the same position in their respective lists.
            """
        case .different:
            return """
            All the related variables take a value that is in a different position in the list for each variable.

            The number of variables must be less or equal than the number of possible values in the lists to make \
            this condition fulfilled.
            """
        }
    }

    var name: String {
        return self.rawValue
    }
}

//do not change the names without checking the comment fixedNames
enum FixedSelectionPriority: String, Codable, CaseIterable {

    case high
    case medium
    case low

    var description: String {
        switch self {
        case .high:
            return """
            This method has higher priority.
            """
        case .medium:
            return """
            This method has medium priority.
            """
        case .low:
            return """
            This method has low priority.
            """
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedCorrectType: String, Codable, CaseIterable {

    case zero = "correct/incorrect"
    case one = "1up/1down"
    case two = "1up/2down"
    case three = "1up/3down"

    var description: String {
        switch self {
        case .zero:
            return """
            After a correct response, the variable value is the first value from its list.
            After an incorrect response, the variable value is the second value from its list.
            If there has been no response yet, the previous response is considered correct.
            So in case the variable is used before giving any response, the variable value is the \
            first value from its list.
            """
        case .one:
            return """
            After a correct response, the variable steps down, to the previous value in its list.
            After an incorrect response, the variable steps up, to the next value in its list.
            """
        case .two:
            return """
            After two consecutive correct responses, the variable steps down, to the previous value in its list.
            After an incorrect response, the variable steps up, to the next value in its list.
            To get to the relevant values faster, a 1up/1down method is applied until the first incorrect response, \
            then the method changes to 1up/2down.
            """
        case .three:
            return """
            After three consecutive correct responses, the variable steps down, to the previous value in its list.
            After an incorrect response, the variable steps up, to the next value in its list.
            To get to the relevant values faster, a 1up/1down method is applied until the first incorrect response, \
            then the method changes to 1up/3down.
            """
        }
    }

    var name: String {
        return self.rawValue
    }
}
