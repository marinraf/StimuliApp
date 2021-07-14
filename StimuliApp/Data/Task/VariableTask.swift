//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class VariableTask: Codable {
    var name: String
    var id: String
    var object: Object?
    var property: Property
    var list: ListOfValues
    var numbers: [Int]
    var values: [Property]
    var unit: String
    var jittering: Bool
    var jitteringValue: Float
    var responseDependency: FixedCorrectType?
    var initialValue: Int = 0
    var trialValueAssociated: VariableTask?

    init(name: String,
         id: String,
         object: Object?,
         property: Property,
         list: ListOfValues,
         numbers: [Int],
         values: [Property],
         unit: String,
         jittering: Bool,
         jitteringValue: Float,
         responseDependency: FixedCorrectType?,
         initialValue: Int) {

        self.name = name
        self.id = id
        self.object = object
        self.property = property
        self.list = list
        self.numbers = numbers
        self.values = values
        self.unit = unit
        self.jittering = jittering
        self.jitteringValue = jitteringValue
        self.responseDependency = responseDependency
        self.initialValue = initialValue
    }

    var info: String {
        var strings: [String] = []

        if responseDependency != nil {
            for _ in 0 ..< values.count {
                strings.append("x")
            }
        } else {
            for value in values {
                strings.append(value.stringWithoutUnit)
            }
        }
        return name + " \(unit): " + strings.joined(separator: ",")
    }

    var shortInfo: String {
        return name + " \(unit)"
    }
}
