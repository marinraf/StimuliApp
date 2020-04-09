//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EnterSeedsModify: Modify {

    var test: Test
    var position: Int
    var manualSeeds: Bool
    var manualDistance: Bool
    var unitDistance: Unit
    var properties: [Property]
    var autoProperties: [Property]
    var seedProperties: [Property]

    init(test: Test, manualSeeds: Bool, manualDistance: Bool) {
        self.test = test
        self.position = 0
        self.manualSeeds = manualSeeds
        self.manualDistance = manualDistance
        self.unitDistance = test.distance.properties[0].unit

        self.properties = test.randomness.properties

        self.autoProperties = properties.filter({ FixedRandomness(rawValue: $0.string)! == .automaticRandomness })
        self.seedProperties = properties.filter({ FixedRandomness(rawValue: $0.string)! == .withSeedsRandomness })

        super.init()

        if manualDistance {
            title = "Distance from the participant to the screen"
            if unitDistance == .cm {
                title += " (cm):"
            } else if unitDistance == .inch {
                title += " (inches):"
            }
        } else {
            title = getName(id: seedProperties[position].somethingId)
        }

        unitType = .positiveIntegerWithoutZero
        isSeed = true
        Task.shared.seeds = []
        calculateAutomatic(properties: autoProperties)
    }

    override func settingInfo() {}

    override func settingPlaceholders() {

        if manualDistance {
            let distanceUnit = test.distance.properties[0].unit
            placeholders[0] = test.distance.properties[0].expressWithoutUnit(as: distanceUnit)
            placeholders[1] = ""
            placeholders[2] = ""
        } else {
            placeholders = ["", "", ""]
        }
    }

    override func save(responses: [String]) -> ResponseStyle {

        if manualDistance {

            let oldValue = test.distance.properties[0].float

            let responseString = responses[0] == "" ? String(oldValue) : responses[0]

            guard let response = Float(responseString) else { return .invalid }

            var newValue = response

            if unitDistance == .inch {
                newValue = response / Constants.cmsInInch
            }

            test.distance.properties[0].changeValue(new: response)

            test.changeAllVisualDegrees(newDistanceCm: newValue, oldDistanceCm: oldValue)

            manualDistance = false

            if manualSeeds {
                title = getName(id: seedProperties[position].somethingId)
                settingPlaceholders()
                return .again
            }
        }

        if manualSeeds {
            let responseString = responses[0] == "" ? "0" : responses[0]

            guard let response = Float(responseString) else { return .invalid }

            let value = UInt64(abs(response))

            let seed = Seed(id: seedProperties[position].somethingId, value: value)
            Task.shared.seeds.append(seed)
            if position < seedProperties.count - 1 {
                position += 1
                title = getName(id: seedProperties[position].somethingId)
                return .again
            }
        }

        Task.shared.error = Task.shared.createTask(test: Flow.shared.test, preview: .no)
        return .seed
    }

    private func calculateAutomatic(properties: [Property]) {
        for property in properties {
            let seed = Seed(id: property.somethingId)
            Task.shared.seeds.append(seed)
        }
    }

    private func getName(id: String) -> String {
        if let list = Flow.shared.test.listsOfValues.first(where: { $0.id == id }) {
            return "seed for list: " + list.name.string
        } else if let section = Flow.shared.test.sections.first(where: { $0.id == id }) {
            return "seed for section: " + section.name.string
        } else {
            return ""
        }
    }
}
