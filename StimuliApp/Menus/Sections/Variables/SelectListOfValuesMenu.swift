//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SelectListOfValuesMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select list")
        sections.append(section)

        for listOfValues in Flow.shared.test.listsOfValues
            where listOfValues.dimensions == Flow.shared.variable.dimensions || listOfValues.dimensions == 8 {
            makeListOfValues(from: listOfValues, sectionNumber: sectionNumber)
        }
        if Flow.shared.variable.dimensions > 3 {
            for listOfValues in Flow.shared.test.listsOfValues
                where listOfValues.dimensions == 1 || listOfValues.dimensions == 8 {
                makeListOfValues(from: listOfValues, sectionNumber: sectionNumber)
            }
        }
        if sections[sectionNumber].options.isEmpty {
            if Flow.shared.variable.dimensions == 2 {
                title2 = """
                There are no lists of 2d vectors. Go to the "List" section to create one.
                """
            } else if Flow.shared.variable.dimensions == 3 {
                title2 = """
                There are no lists of 3d colors. Go to the "List" section to create one.
                """
            } else {
                title2 = """
                There are no lists. Go to the "List" section to create one.
                """
            }
        } else {
            title2 = ""
        }
    }

    // MARK: - Options
    private func makeListOfValues(from listOfValues: ListOfValues, sectionNumber: Int) {
        var option = Option(name: listOfValues.name.string + ": " + listOfValues.detail)
        option.style = .onlySelect
        option.nextScreen = {

            if listOfValues.dimensions == 8 {
                if let vari = Flow.shared.test.variables.first(where: { $0.group == -1 }) {
                    vari.group = 0
                    vari.listOfValuesId = ""
                }
                Flow.shared.variable.group = -1
            } else if Flow.shared.variable.group == -1 {
                Flow.shared.variable.group = 0
            }

            Flow.shared.variable.listOfValuesId = listOfValues.id

            if Flow.shared.section.trialValue.somethingId == Flow.shared.variable.id {
                Flow.shared.section.trialValue.addProperties()
            }
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
