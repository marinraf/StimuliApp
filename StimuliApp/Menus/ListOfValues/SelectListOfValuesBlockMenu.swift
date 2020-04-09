//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SelectListOfValuesBlockMenu: Menu {

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
            where listOfValues.dimensions <= 3 {
            makeListOfValues(from: listOfValues, sectionNumber: sectionNumber)
        }

        if sections[sectionNumber].options.isEmpty {
                title2 = """
                There are no lists you can use. Go to the "List" section to create one.
                """
        }
    }

    // MARK: - Options
    private func makeListOfValues(from listOfValues: ListOfValues, sectionNumber: Int) {
        var option = Option(name: listOfValues.name.string + ": " + listOfValues.detail)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.property.somethingId = listOfValues.id
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
