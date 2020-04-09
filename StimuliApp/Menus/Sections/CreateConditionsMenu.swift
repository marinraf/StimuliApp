//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class CreateConditionsMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select condition")
        sections.append(section)
        for (index, condition) in FixedCondition.allCases.enumerated() {
            makeCondition(from: condition, position: index, sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeCondition(from condition: FixedCondition, position: Int, sectionNumber: Int) {
        var option = Option(name: condition.name)
        option.style = .onlySelect
        option.nextScreen = {
            let newProperty = Property(name: condition.name(n: 1),
                                       info: condition.name,
                                       propertyType: .simpleFloat,
                                       unitType: .positiveIntegerOrZero,
                                       fixedValues: FixedCondition.allCases.map({ $0.name }),
                                       selectedValue: position)
            newProperty.text = "End the test"

            Flow.shared.section.next.properties.append(newProperty)
            newProperty.float = 1
            for (index, element) in Flow.shared.section.next.properties.enumerated() {
                element.listOrder = index
            }
            Flow.shared.saveTest(Flow.shared.test)

            switch condition {
            case .lastCorrect, .lastIncorrect:
                return nil
            case .numberCorrects, .numberOfTrials, .numberIncorrects, .numberOfResponses:
                let modify = Modify(title: "number of trials",
                                    info: "number of trials",
                                    property: newProperty)
                modify.saveFunctionFloats = { response in
                    if response.count > 0 {
                        let n = Int(response[0])
                        if n > 0 {
                            newProperty.changeValue(new: response)
                            newProperty.name = condition.name(n: n)
                            Flow.shared.saveTest(Flow.shared.test)
                        }
                    }
                    return .saved
                }
                return modify
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
