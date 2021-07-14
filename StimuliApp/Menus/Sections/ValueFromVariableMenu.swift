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
        for list in Flow.shared.test.listsOfValues where [1, 2, 3].contains(list.dimensions) {
            makeListOption(from: list, sectionNumber: sectionNumber)
        }
        for variable in Flow.shared.section.allVariables {
            if variable.name != "__trialValue" {
                makeVariable(from: variable, sectionNumber: sectionNumber)
            }
        }
    }

    // MARK: - Options
    private func makeVariable(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)

        Flow.shared.section.trialValueVariable = nil

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
        var option = Option(name: "fixed value = 0")

        Flow.shared.section.trialValueVariable = nil

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

    private func makeListOption(from list: ListOfValues, sectionNumber: Int) {
        var option = Option(name: "create new variable from list: \(list.name.string)")

        let variable = Variable()
        variable.listOfValuesId = list.id
        variable.selection = VariableData.makeSelectionProperty(selected: 0)
//        variable.objectId = Flow.shared.section.objects[0].id
        variable.propertyId = Flow.shared.section.trialValue.id


        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.trialValueVariable = variable
            Flow.shared.section.trialValue.somethingId = variable.id
            Flow.shared.section.trialValue.addProperties()
            Flow.shared.section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
