//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ResultsMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveResults(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Results")
        sections.append(section)
        for result in Flow.shared.results {
            makeResult(from: result, sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeResult(from result: Result, sectionNumber: Int) {
        var option = Option(name: result.name.string)
        option.style = .optional
        option.detail = result.responseKeyboard + " " + result.dateString
        option.nextScreen = {
            Flow.shared.result = result
            return InfoExport(type: .infoResult)
        }
        option.deleteTexts = Flow.shared.deleteResultTexts()
        option.delete = {
            Flow.shared.deleteResult(result)
            return []
        }
        sections[sectionNumber].options.append(option)
    }
}
