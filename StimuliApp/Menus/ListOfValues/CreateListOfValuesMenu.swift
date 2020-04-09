//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class CreateListOfValuesMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Create a new list")
        sections.append(section)
        makeNewValues(sectionNumber: sectionNumber)
        makeNewValuesDoble(sectionNumber: sectionNumber)
        makeNewValuesTriple(sectionNumber: sectionNumber)
        makeNewValuesImage(sectionNumber: sectionNumber)
        makeNewValuesText(sectionNumber: sectionNumber)
        makeNewValuesVideo(sectionNumber: sectionNumber)
        makeNewValuesAudio(sectionNumber: sectionNumber)
        makeNewValuesBlock(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeNewValues(sectionNumber: Int) {
        var option = Option(name: "new list of numeric values")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .values) {
                return EditListOfValuesMenu(title: "List of numeric values")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesDoble(sectionNumber: Int) {
        var option = Option(name: "new list of 2d vectors (size or position)")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .vectors) {
                return EditListOfValuesDoble(title: "List of 2d vectors")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesTriple(sectionNumber: Int) {
        var option = Option(name: "new list of 3d vectors (color)")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .colors) {
                Flow.shared.listOfValues.jittering.unitType = .valueFrom0to1
                return EditListOfValuesTriple(title: "List of colors")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesImage(sectionNumber: Int) {
        let image = Flow.shared.test.listsOfValues.first(where: { $0.type == .images })
        guard image == nil else { return }
        var option = Option(name: "new list of images")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .images) {
                return EditListOfValuesImage(title: "List of")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesText(sectionNumber: Int) {
        let text = Flow.shared.test.listsOfValues.first(where: { $0.type == .texts })
        guard text == nil else { return }
        var option = Option(name: "new list of texts")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .texts) {
                return EditListOfValuesText(title: "List of")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesVideo(sectionNumber: Int) {
        let video = Flow.shared.test.listsOfValues.first(where: { $0.type == .videos })
        guard video == nil else { return }
        var option = Option(name: "new list of videos")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .videos) {
                return EditListOfValuesVideo(title: "List of")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesAudio(sectionNumber: Int) {
        let audio = Flow.shared.test.listsOfValues.first(where: { $0.type == .audios })
        guard audio == nil else { return }
        var option = Option(name: "new list of audios")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .audios) {
                return EditListOfValuesAudio(title: "List of")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValuesBlock(sectionNumber: Int) {
        let block = Flow.shared.test.listsOfValues.first(where: { $0.type == .blocks })
        guard block == nil else { return }
        var option = Option(name: "new list of blocks")
        option.style = .insert
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewListOfValues(type: .blocks) {
                return EditListOfValuesBlock(title: "List of")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
