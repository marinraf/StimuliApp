//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditObjectMenu: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.object.name.string
        backButton = "< Scene:  \(Flow.shared.scene.name.string)"
        buttonImage = "preview scene"

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
        makeSection3()
        makeSection4()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Object name")
        section.dependency = Flow.shared.object.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.object.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.scene.objects.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Object from stimulus")
        section.dependency = Flow.shared.object.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeNewObject(sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "Object type")
        section.dependency = Flow.shared.object.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.object.typeProperty, sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "Object shape")
        section.dependency = Flow.shared.object.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.object.shapeProperty, sectionNumber: sectionNumber)
    }

    private func makeSection4() {
        let sectionNumber = 4
        let section = MenuSection(title: "Object variables")
        section.dependency = Flow.shared.object.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        for variable in Flow.shared.object.variables {
            makeVariable(from: variable, sectionNumber: sectionNumber)
        }
        if Flow.shared.object.variables.count == 0 {
            makeEmptyOption(sectionNumber: sectionNumber)
        }
    }

    // MARK: - Options
    private func makeVariable(from variable: Variable, sectionNumber: Int) {
        var option = Option(name: variable.name)
        option.style = .onlyInfo
        sections[sectionNumber].options.append(option)
    }

    private func makeEmptyOption(sectionNumber: Int) {
        var option = Option(name: "There are no variables.")
        option.style = .onlyInfo
        option.infoMessage = "The object has no variable properties."
        option.nextScreen = {
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewObject(sectionNumber: Int) {
        var option = Option(name: "stimulus:")
        option.detail = Flow.shared.object.stimulusProperty.string
        option.style = .standard
        option.infoMessage = "stimulus name"
        option.nextScreen = {
            return ObjectFromStimulusMenu2(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }
}
