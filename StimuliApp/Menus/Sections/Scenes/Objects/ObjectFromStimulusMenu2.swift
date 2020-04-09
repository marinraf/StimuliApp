//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ObjectFromStimulusMenu2: Menu {

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
            makeStimulus(from: stimulus,
                         scene: Flow.shared.scene,
                         object: Flow.shared.object,
                         sectionNumber: sectionNumber)
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
    private func makeStimulus(from stimulus: Stimulus, scene: Scene, object: Object, sectionNumber: Int) {
        var option = Option(name: stimulus.name.string)
        option.style = .onlySelect

        option.nextScreen = {
            let previousOrder = object.order
            Flow.shared.deleteObject(object)
            _ = Flow.shared.createSaveAndSelectNewObject(from: stimulus, scene: scene)
            Flow.shared.moveObjects(Flow.shared.object.order, to: previousOrder)

            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
