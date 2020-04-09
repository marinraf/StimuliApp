//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class TestsMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
        makeSection1()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveTests(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Tests")
        sections.append(section)
        for test in Flow.shared.tests {
            makeTest(from: test, sectionNumber: sectionNumber)
        }
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "")
        sections.append(section)
        makeNewTest(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeTest(from test: Test, sectionNumber: Int) {
        var option = Option(name: test.name.string)
        option.style = .optional
        option.canDuplicate = true
        option.nextScreen = {
            Flow.shared.test = test
            Flow.shared.initTabControllerTest()
            Flow.shared.tabBarIsMenu = false
            Flow.shared.settings.update(from: test)
            return EditTestMenu(title: "Test")
        }
        option.deleteTexts = Flow.shared.deleteTestTexts()
        option.delete = {
            Flow.shared.deleteTest(test)
            return []
        }
        option.duplicate = {
            _ = Flow.shared.createAndSaveNewTest(from: test)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewTest(sectionNumber: Int) {
        var option = Option(name: "+ new test")
        option.style = .insert
        option.infoMessage = "To create a new test."
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewTest() {
                Flow.shared.initTabControllerTest()
                Flow.shared.tabBarIsMenu = false
                return EditTestMenu(title: "Test")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
