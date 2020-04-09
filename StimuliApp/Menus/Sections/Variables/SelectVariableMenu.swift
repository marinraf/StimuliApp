//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SelectVariableMenu: Menu {

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
        var otherVars = 0
        for variable in Flow.shared.section.variables where variable !== Flow.shared.variable {
            otherVars += 1
            if variable.group == 0 {
                makeVariable(from: variable, sectionNumber: sectionNumber)
            }
        }
        if sections[sectionNumber].options.isEmpty {
            if otherVars == 0 {
                title2 = "there are no other variables"
            } else {
                title2 = """
                there are no other variables that can be added
                (variables in other groups or that use blocks cannot be added)
                """
            }
        } else {
            title2 = ""
        }
    }

    // MARK: - Options
    private func makeVariable(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)
        option.style = .onlySelect
        option.nextScreen = {
            if Flow.shared.variable.inGroup {
                variable.group = Flow.shared.variable.group
                if let selection = FixedSelection(rawValue: variable.selection.string) {
                    if selection == .fixed {
                        let newProperty = VariableData.makePropertyToAddToSelection(variable: variable)
                        for varInGroup in Flow.shared.variable.allVariablesInSameGroup(section: Flow.shared.section) {
                            varInGroup.selection.properties.append(newProperty)
                        }
                    }
                }
                variable.selection = Property(from: Flow.shared.variable.selection)
            } else {
                variable.group = Flow.shared.section.maximumGroup + 1
                Flow.shared.variable.group = variable.group
                Flow.shared.group = variable.group
                Flow.shared.variable.selection.somethingId = String(variable.group)
                Flow.shared.variable.selection.addProperties()
                variable.selection = Property(from: Flow.shared.variable.selection)
            }
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
