//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SectionsMenu: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.test.name.string

        sections = []
        makeSection0()
        makeSection1()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveSections(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Sections")
        sections.append(section)
        for sectionMenu in Flow.shared.test.sections {
            makeSection(from: sectionMenu, sectionNumber: sectionNumber)
        }
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "")
        sections.append(section)
        makeNewSection(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeSection(from section: Section, sectionNumber: Int) {
        var option = Option(name: section.name.string)
        option.style = .optional
        option.canDuplicate = true
        option.nextScreen = {
            Flow.shared.section = section
            return EditSectionMenu(title: "Section")
        }
        option.deleteTexts = Flow.shared.deleteSectionTexts()
        option.delete = {
            Flow.shared.deleteSection(section)
            return []
        }
        option.duplicate = {
            _ = Flow.shared.createAndSaveNewSection(from: section)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewSection(sectionNumber: Int) {
        var option = Option(name: "+ new section")
        option.style = .insert
        option.infoMessage = "To create a new section."
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewSection() {
                return EditSectionMenu(title: "Section")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
