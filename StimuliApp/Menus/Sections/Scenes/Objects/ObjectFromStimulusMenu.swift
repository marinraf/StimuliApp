//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ObjectFromStimulusMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select stimulus to create object from")
        sections.append(section)
        for stimulus in Flow.shared.test.stimuli {
            makeStimulus(from: stimulus, scene: Flow.shared.scene, sectionNumber: sectionNumber)
        }
        if Flow.shared.test.stimuli.isEmpty {
            title2 = """
            There are no stimuli in this test.
            To create an object for this scene, first go to the stimuli section and create some \
            stimuli to make objects from.
            """
        } else {
            title2 = ""
        }
    }

    // MARK: - Options
    private func makeStimulus(from stimulus: Stimulus, scene: Scene, sectionNumber: Int) {
        var option = Option(name: stimulus.name.string)
        option.style = .onlySelect
        option.nextScreen = {
            _ = Flow.shared.createSaveAndSelectNewObject(from: stimulus, scene: scene)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
