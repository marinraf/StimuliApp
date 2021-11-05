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
            let newProperty = Property(name: condition.name(n: 1, a: 0),
                                       info: condition.name,
                                       propertyType: .simpleFloat,
                                       unitType: .positiveIntegerWithoutZero,
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
            case .lastCorrect, .lastIncorrect, .lastResponded, .lastNotResponded:
                return nil
            case .numberCorrects, .numberOfTrials, .numberIncorrects, .numberOfResponses, .numberOfNotResponses:
                let modify = Modify(title: "number of trials",
                                    info: "number of trials",
                                    property: newProperty)
                modify.saveFunctionFloats = { response in
                    if response.count > 0 {
                        newProperty.changeValue(new: response)
                        let n = Int(newProperty.float)
                        newProperty.name = condition.name(n: n, a: 0)
                        Flow.shared.saveTest(Flow.shared.test)
                    }
                    return .saved
                }
                return modify


            case .biggerAccuracy, .smallerAccuracy:

                newProperty.propertyType = .trialAccuracy
                newProperty.unitType = .twoValues

                let modify = Modify(title: "number of trials and accuracy",
                                    info: """
                                          Number of trials (n) & accuracy (a).

                                          When the number of trials performed is a multiple of n, \
                                          the accuracy of the last n trials is compared with the value a.

                                          The accuracy of the last n trials is calculated as:
                                          number of correct trials in the last n trials / n.

                                          For example if n is set to 20 and a is set to 0.6, we will compare:

                                          accuracy of the task in trials  1...20 vs 0.6 when trial = 20
                                          accuracy of the task in trials 21...40 vs 0.6 when trial = 40
                                          accuracy of the task in trials 41...60 vs 0.6 when trial = 60

                                          etc
                                          """,
                                    property: newProperty)
                modify.saveFunctionFloats = { response in
                    if response.count > 0 {
                        newProperty.changeValue(new: response)
                        let n = Int(newProperty.float)
                        let a = newProperty.float1
                        newProperty.name = condition.name(n: n, a: a)
                        Flow.shared.saveTest(Flow.shared.test)
                    }
                    return .saved
                }
                return modify
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
