//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditSectionMenu: Menu {

    var deleting = false

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.section.name.string
        backButton = "< Sections"
        buttonImage = "preview variables"
        secondMoveSection = 7

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
        makeSection3()
        makeSection4()
        makeSection5()
        makeSection6()
        makeSection7()
        makeSection8()
        makeSection9()
    }

    override func moveFunction(_ first: Int, to second: Int) {
            Flow.shared.moveScenes(first, to: second)
    }

    override func moveFunction2(_ first: Int, to second: Int) {
            Flow.shared.moveConditions(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Section name")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.section.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.test.sections.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Scenes")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        for scene in Flow.shared.section.scenes {
            makeScene(from: scene, sectionNumber: sectionNumber)
        }
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed
        sections.append(section)
        makeNewScene(sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "Variables in the section")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        var groups: [Int] = []
        for variable in Flow.shared.section.allVariables where !groups.contains(variable.group) {
            makeVariable(from: variable, sectionNumber: sectionNumber)
            if variable.group != 0 {
                groups.append(variable.group)
            }
        }

        if sections.last!.options.isEmpty && !deleting {
            makeEmptyOption(sectionNumber: sectionNumber)
        }
        deleting = false
    }

    private func makeSection4() {
        let sectionNumber = 4
        let section = MenuSection(title: "Repetitions and trials")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        if Flow.shared.section.managedByBlocks {
            makeRepetitions(sectionNumber: sectionNumber)
        } else {
            makeOption(from: Flow.shared.section.repetitions, sectionNumber: sectionNumber)
        }
        makeDifferentPossibilities(sectionNumber: sectionNumber)
        makeTotalPossibilities(sectionNumber: sectionNumber)
    }

    private func makeSection5() {
        let sectionNumber = 5
        let section = MenuSection(title: "Trial value")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        let value = Flow.shared.section.trialValue
        makeValue(from: value, sectionNumber: sectionNumber)
    }

    private func makeSection6() {
        let sectionNumber = 6
        let section = MenuSection(title: "Response value")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        let responseValue = Flow.shared.section.responseValue
        makeResponseValue(from: responseValue, sectionNumber: sectionNumber)
    }

    private func makeSection7() {
        let sectionNumber = 7
        let section = MenuSection(title: "End of trial conditions")
        section.dependency = Flow.shared.section.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        let next = Flow.shared.section.next
        for property in next.properties {
            makeNext(from: property, optional: true, sectionNumber: sectionNumber)
        }
    }

    private func makeSection8() {
        let sectionNumber = 8
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed

        sections.append(section)
        makeNewNext(sectionNumber: sectionNumber)
    }

    private func makeSection9() {
        let sectionNumber = 9
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed
        sections.append(section)
        makeNext(from: Flow.shared.section.next, optional: false, sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeScene(from scene: Scene, sectionNumber: Int) {
        var option = Option(name: scene.name.string)
        option.style = .optional
        option.infoMessage = Texts.sceneOrder
        option.nextScreen = {
            Flow.shared.scene = scene
            return EditSceneMenu(title: "Scene")
        }
        option.deleteTexts = Flow.shared.deleteSceneTexts()
        option.delete = { [weak self] in
            var indices: [IndexPath] = []
            var i = 0
            for newScene in Flow.shared.section.scenes {
                for object in newScene.objects {
                    for _ in object.variables {
                        if newScene === scene {
                            indices.append(IndexPath(row: i, section: sectionNumber + 2))
                            self?.deleting = true
                        }
                        i += 1
                    }
                }
            }
            if Flow.shared.section.responseValue.somethingId == scene.id {
                indices.append(IndexPath(row: 1, section: sectionNumber + 5))
            }
            Flow.shared.deleteScene(scene)
            return indices
        }
        option.duplicate = {
            _ = Flow.shared.createAndSaveNewScene(from: scene)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewScene(sectionNumber: Int) {
        var option = Option(name: "+ new scene")
        option.style = .insert
        option.infoMessage = Texts.newScene
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewScene() {
                return EditSceneMenu(title: "Scene")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeVariable(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)
        if variable.inGroup {
            option.detail = variable.otherVariablesInSameGroup(section: Flow.shared.section).map({
                $0.name }).joined(separator: ",")
        }
        option.infoMessage = Texts.variablesInSection
        option.style = .onlySelect

        if let object = variable.object, let scene = variable.scene  {
            option.nextScreen = {
                Flow.shared.variable = variable
                Flow.shared.object = object
                Flow.shared.scene = scene
                Flow.shared.group = variable.group
                return EditVariableMenu(title: "Variable")
            }
        } else {
            option.nextScreen = {
                Flow.shared.variable = variable
                Flow.shared.group = variable.group
                return EditVariableMenu(title: "Variable")
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeEmptyOption(sectionNumber: Int) {
        var option = Option(name: "There are no variables.")
        option.style = .onlyInfo
        option.infoMessage = Texts.variablesInSection
        option.nextScreen = {
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeRepetitions(sectionNumber: Int) {
        var option = Option(name: "repetitions")
        option.style = .onlyInfo
        option.detail = "1"
        option.infoMessage = Texts.repetitionsBlock
        option.nextScreen = {
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeDifferentPossibilities(sectionNumber: Int) {
        var option = Option(name: "numberOfDifferentTrials")
        option.style = .onlyInfo
        option.detail = String(Flow.shared.section.differentPossibilities)
        option.infoMessage = Texts.differentTrials
        option.nextScreen = {
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeTotalPossibilities(sectionNumber: Int) {
        var option = Option(name: "totalNumberOfTrials")
        option.style = .onlyInfo
        option.detail = String(Flow.shared.section.totalPossibilities)
        option.infoMessage = Texts.totalNumberOfTrials
        option.nextScreen = {
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeValue(from value: Property, sectionNumber: Int) {
        var name = value.variable?.name ?? "fixed value = 0"
        if name == "__trialValue" {
            if let listName = value.variable?.listOfValues?.name.string {
                name = listName
            }
        }
        var option = Option(name: "trialValueVariable:")
        option.style = .standard
        option.detail = name
        option.infoMessage = Texts.trialValueVariable
        option.nextScreen = {
            return ValueFromVariableMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)

        for element in value.properties {
            makeOption(from: element, sectionNumber: sectionNumber, position: 1)
        }
    }

    private func makeResponseValue(from correct: Property, sectionNumber: Int) {
        var name = "none"
        for scene in Flow.shared.test.scenes where scene.id == correct.somethingId {
            let name2 = FixedCorrect.allCases[correct.selectedValue].name
            name = scene.name.string + "_" + name2
        }
        var option = Option(name: "responseValueParameter:")
        option.infoMessage = Texts.responseValueParameter
        if Flow.shared.section.responseValue.somethingId == "" {
            option.detail = "none"
        }

        option.style = .standard
        option.detail = name
        option.nextScreen = {
            return CorrectFromResponseMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)

        for element in correct.properties {
            makeOption(from: element, sectionNumber: sectionNumber, position: 1)
        }
    }

    private func makeNewNext(sectionNumber: Int) {
        var option = Option(name: "+ new condition")
        option.style = .insert
        option.infoMessage = Texts.newCondition
        option.nextScreen = {
            return CreateConditionsMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNext(from property: Property, optional: Bool, sectionNumber: Int) {
        var option = Option(name: property.name + ":")
        if optional {
            option.style = .optional
        }
        if property.somethingId == "" {
            option.detail = property.text
            option.infoMessage = Texts.condition
        } else {
            option.detail = property.nameToShow
            option.infoMessage = property.info
        }
        option.nextScreen = {
            Flow.shared.property = property
            return EditConditionMenu(title: "", style: .select)
        }
        option.deleteTexts = Flow.shared.deleteConditionTexts()
        option.delete = {
            Flow.shared.deleteCondition(property)
            return []
        }
        sections[sectionNumber].options.append(option)
    }
}
