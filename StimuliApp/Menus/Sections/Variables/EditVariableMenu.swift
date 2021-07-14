//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditVariableMenu: Menu {

    // MARK: - Setting
    override func setting() {
        guard Flow.shared.variable.property?.timeDependency == .variable || Flow.shared.variable.realName == "__trialValue" else {
            sections = []
            title2 = "This variable no longer exists"
            backButton = "< Section: \(Flow.shared.section.name.string)"
            return
        }
        buttonImage = "preview scene"

        let group = Flow.shared.variable.group

        if group != -1 {
            Flow.shared.variable = Flow.shared.variable.allVariablesInSameGroup(section: Flow.shared.section)[0]
        }

        title2 = Flow.shared.variable.name
        backButton = "< Section: \(Flow.shared.section.name.string)"

        sections = []
        makeSection0()
        makeSection1()

        if group != -1 {
            makeSection2()
            makeSection3()
        }
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Variable and values")
        section.dependency = Flow.shared.variable.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOtherVariableOption(from: Flow.shared.variable, sectionNumber: sectionNumber)
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Related variables")
        section.dependency = Flow.shared.variable.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        let allVariablesInSameGroup = Flow.shared.variable.allVariablesInSameGroup(section: Flow.shared.section)
        for variable in allVariablesInSameGroup where variable !== Flow.shared.variable {
            makeOtherVariableOption(from: variable, sectionNumber: sectionNumber)
        }
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed
        sections.append(section)
        makeNewVariable(sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        if Flow.shared.variable.listOfValues != nil {
            let section = MenuSection(title: "Selection method")
            section.dependency = Flow.shared.variable.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.variable.selection, sectionNumber: sectionNumber)
            guard let selection = FixedSelection(rawValue: Flow.shared.variable.selection.string) else { return }
            if selection == .inOrder || selection == .shuffled {
                makeAlternatedVariable(sectionNumber: sectionNumber)
            }
        }
    }

    // MARK: - Options
    private func makeOtherVariableOption(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)
        if variable === Flow.shared.variable {
            option.style = .standard
            option.infoMessage = "Select the list of values from which this variable gets its values."
        } else {
           option.style = .optionalInfo
            option.infoMessage = """
            This variable shares the same selection method as the first variable.

            Select the list of values from which this variable gets its values.

            The number of possible values for all the related variables must be the same.
            Therefore, all the lists from which these variables get values must have the same number of elements.
            """
        }
        option.detail = variable.listOfValues?.valuesString ?? ""
        if let list = variable.listOfValues {
            let name = list.name.string
            let detail = list.detail
            if list.dimensions == 8 {
                option.detail = detail
            } else {
                option.detail = detail + " from: " + name
            }
        } else {
            option.detail = "no values"
        }

        if variable.realName == "__trialValue"  {
            option.nextScreen = { nil }
        } else {
            option.nextScreen = {
                Flow.shared.variable = variable
                return SelectListOfValuesMenu(title: "", style: .select)
            }
        }

        option.delete = { [weak self] in
            var indices: [IndexPath] = []
            if let sections = self?.sections {
                if sections.count > sectionNumber + 2 {
                    let sectionToUse = sections[sectionNumber + 2]
                    for (index, option) in sectionToUse.options.enumerated() {
                        if option.name == variable.name + "Value:" || option.name == variable.name + "InitialValue:" {
                            let indexPath = IndexPath(row: index, section: sectionNumber + 2)
                            indices += [indexPath]
                        }
                    }
                }
            }
            if let select = FixedSelection(rawValue: variable.selection.string) {
                if select == .random {
                    if variable.otherVariablesInSameGroup(section: Flow.shared.section).count == 1 {
                        let newIndex = IndexPath(row: 1, section: sectionNumber + 2)
                        indices += [newIndex]
                    }
                }
            }
            Flow.shared.deleteVariableFromGroup(variable)
            return indices
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewVariable(sectionNumber: Int) {
        var option = Option(name: "+ add related variable")
        option.style = .insert
        option.infoMessage = """
        Add a new related variable that will share the same method to select its values.

        The number of possible values for all the related variables must be the same.
        Therefore, all the lists from which these variables get values must have the same number of elements.
        """
        option.nextScreen = {
            return SelectVariableMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeAlternatedVariable(sectionNumber: Int) {
        var option = Option(name: "alternatedVariable: ")
        option.style = .selectFromSegment
        var segment1 = Segment(title: "no")
        var segment2 = Segment(title: "yes")

        segment1.action = {
            Flow.shared.section.alternate =  ""
            Flow.shared.saveTest(Flow.shared.test)
        }
        segment2.action = {
            Flow.shared.section.alternate = Flow.shared.variable.id
            Flow.shared.saveTest(Flow.shared.test)
        }
        option.segments = [segment1, segment2]

        var isAlternated = 0
        if let variable = Flow.shared.test.allVariables.first(where: { $0.id == Flow.shared.section.alternate }) {
            if variable === Flow.shared.variable {
                isAlternated = 1
            }
        }

        option.selectedSegment = isAlternated
        option.position = 1

        option.infoMessage = """
        There can only be one variable (or group of variables) of alternate type.
        This variable goes through all its values (in order or randomly) before starting with another \
        repetition of all its values.
        """

        sections[sectionNumber].options.append(option)
    }
}
