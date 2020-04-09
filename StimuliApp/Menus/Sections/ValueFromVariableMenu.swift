//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ValueFromVariableMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select variable")
        sections.append(section)
        makeEmptyOption(sectionNumber: sectionNumber)
        for variable in Flow.shared.section.variables {
            makeVariable(from: variable, sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeVariable(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.trialValue.somethingId = variable.id
            Flow.shared.section.trialValue.addProperties()
            Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeEmptyOption(sectionNumber: Int) {
        var option = Option(name: "none")
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.trialValue.somethingId = ""
            Flow.shared.section.trialValue.addProperties()
            Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
