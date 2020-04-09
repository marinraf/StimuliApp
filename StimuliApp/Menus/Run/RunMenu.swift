//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class RunMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Run Test")
        sections.append(section)
        for test in Flow.shared.tests {
            makeTest(from: test, sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeTest(from test: Test, sectionNumber: Int) {
        var option = Option(name: "Run: " + test.name.string)
        option.style = .runTest
        option.nextScreen = {
            Flow.shared.test = test
            var manualDistance = false
            let distance = FixedDistance(rawValue: test.distance.string) ?? .dependent
            if distance == .dependent {
                manualDistance = true
            }
            var manualSeeds = false
            let properties = test.randomness.properties
            for property in properties {
                if let random = FixedRandomness(rawValue: property.string) {
                    if random == .withSeedsRandomness {
                        manualSeeds = true
                    }
                }
            }
            if manualSeeds || manualDistance {
                return EnterSeedsModify(test: test, manualSeeds: manualSeeds, manualDistance: manualDistance)
            } else {
                Task.shared.error = Task.shared.createTask(test: Flow.shared.test, preview: .no)
                if Task.shared.error == "" {
                    return Display()
                } else {
                    return InfoExport(type: .previewErrorStimulusOrTest)
                }
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
