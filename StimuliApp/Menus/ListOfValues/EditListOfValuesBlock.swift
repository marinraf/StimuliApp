//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditListOfValuesBlock: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.listOfValues.name.string
        backButton = "< Lists"

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()

        if Flow.shared.listOfValues.typesOfBlocks.selectedValue == 0 {
            makeSection3A()
        } else {
            makeSection3()
            makeSection4()
        }
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveValuesValues(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "List name")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.test.listsOfValues.map({ $0.name.string }))
    }


    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Repetitions")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.numberOfBlocks, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.lengthOfBlocks, sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "Types of blocks")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.typesOfBlocks, sectionNumber: sectionNumber)
        if Flow.shared.listOfValues.typesOfBlocks.selectedValue != 0 {
            makeOption(from: Flow.shared.listOfValues.startingBlock, sectionNumber: sectionNumber)
            makeOption(from: Flow.shared.listOfValues.probChangeBlock, sectionNumber: sectionNumber)
        }


    }

    private func makeSection3A() {
        let sectionNumber = 3
        let section = MenuSection(title: "Block")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOtherVariableOption(from: Flow.shared.listOfValues.firstList, sectionNumber: sectionNumber)
        makeOtherVariableOption(from: Flow.shared.listOfValues.secondList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.startingList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.probChangeList, sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "First Block")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOtherVariableOption(from: Flow.shared.listOfValues.firstBlockFirstList, sectionNumber: sectionNumber)
        makeOtherVariableOption(from: Flow.shared.listOfValues.firstBlockSecondList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.firstBlockStartingList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.firstBlockProbChangeList, sectionNumber: sectionNumber)
    }

    private func makeSection4() {
        let sectionNumber = 4
        let section = MenuSection(title: "Second Block")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOtherVariableOption(from: Flow.shared.listOfValues.secondBlockFirstList, sectionNumber: sectionNumber)
        makeOtherVariableOption(from: Flow.shared.listOfValues.secondBlockSecondList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.secondBlockStartingList, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.listOfValues.secondBlockProbChangeList, sectionNumber: sectionNumber)
    }


    // MARK: - Options
    private func getSections() -> [Section] {
        var result: [Section] = []
        for variable in Flow.shared.test.allVariables where variable.listOfValuesId == Flow.shared.listOfValues.id {
            for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {
                result.append(section)
            }
        }
        return result
    }

    private func makeOtherVariableOption(from property: Property, sectionNumber: Int) {

        var option = Option(name: property.name)
        option.style = .standard

        option.infoMessage = """
        The list you want to use.
        """

        if let list = property.listOfValues {
            let name = list.name.string
            let detail = list.detail
            option.detail = detail + " from: " + name
        } else {
            option.detail = "no values"
        }

        option.nextScreen = {
            Flow.shared.property = property
            return SelectListOfValuesBlockMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }

}
