//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ListsOfValuesMenu: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.test.name.string

        sections = []

        makeSection0()
        makeSection1()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveListsOfValues(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "List")
        sections.append(section)
        for values in Flow.shared.test.listsOfValues {
            makeValues(from: values, sectionNumber: sectionNumber)
        }
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "")
        sections.append(section)
        makeNewValues(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeValues(from listOfValues: ListOfValues, sectionNumber: Int) {
        var option = Option(name: listOfValues.name.string)
        option.style = .optional
        option.canDuplicate = listOfValues.dimensions < 4
        option.detail = listOfValues.detail
        option.nextScreen = {
            Flow.shared.listOfValues = listOfValues
            if listOfValues.dimensions == 1 {
                return EditListOfValuesMenu(title: "List of numeric values")
            } else if listOfValues.dimensions == 2 {
                return EditListOfValuesDoble(title: "List of 2d vectors")
            } else if listOfValues.dimensions == 3 {
                return EditListOfValuesTriple(title: "List of colors (3d vectors)")
            } else if listOfValues.dimensions == 4 {
                return EditListOfValuesImage(title: "List of")
            } else if listOfValues.dimensions == 5 {
                return EditListOfValuesText(title: "List of")
            } else if listOfValues.dimensions == 6 {
                return EditListOfValuesVideo(title: "List of")
            } else if listOfValues.dimensions == 7 {
                return EditListOfValuesAudio(title: "List of")
            } else if listOfValues.dimensions == 8 {
                return EditListOfValuesBlock(title: "List of")
            } else {
                return nil
            }
        }
        option.duplicate = {
            _ = Flow.shared.createAndSaveNewListOfValues(from: listOfValues)
            return []
        }
        option.deleteTexts = Flow.shared.deleteListOfValuesTexts(listOfValues)
        option.delete = {
            Flow.shared.deleteListOfValues(listOfValues)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValues(sectionNumber: Int) {
        var option = Option(name: "+ new list")
        option.style = .insert
        option.infoMessage = "To create a new list."
        option.nextScreen = {
            return CreateListOfValuesMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }
}
