///  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SelectFirstSectionMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select first section")
        sections.append(section)
        for item in Flow.shared.test.sections {
            makeFirstSection(from: item, sectionNumber: sectionNumber)
        }
        if Flow.shared.test.sections.isEmpty {
            title2 = """
            There are still no sections in this test.
            To create a section, go to the corresponding menu.
            """
        } else {
            title2 = ""
        }
    }

    // MARK: - Options
    private func makeFirstSection(from section: Section, sectionNumber: Int) {
        let name = section.name.string
        var option = Option(name: name)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.test.firstSection.somethingId = section.id
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
