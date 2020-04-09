//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditConditionMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select section")
        sections.append(section)
        makeEmptyOption(sectionNumber: sectionNumber)
        for item in Flow.shared.test.sections where item !== Flow.shared.section {
            makeSection(from: item, sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeSection(from section: Section, sectionNumber: Int) {
        let name = section.name.string
        var option = Option(name: name)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.property.somethingId = section.id
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeEmptyOption(sectionNumber: Int) {
        var option = Option(name: "End the test")
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.property.somethingId = ""
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
