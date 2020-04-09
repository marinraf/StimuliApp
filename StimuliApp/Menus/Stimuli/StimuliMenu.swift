//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class StimuliMenu: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.test.name.string

        sections = []
        makeSection0()
        makeSection1()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveStimuli(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Stimuli")
        sections.append(section)
        for stimulus in Flow.shared.test.stimuli {
            makeStimulus(from: stimulus, sectionNumber: sectionNumber)
        }
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "")
        sections.append(section)
        makeNewStimulus(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeStimulus(from stimulus: Stimulus, sectionNumber: Int) {
        var option = Option(name: stimulus.name.string)
        option.detail = stimulus.info
        option.style = .optional
        option.canDuplicate = true
        option.nextScreen = {
            Flow.shared.stimulus = stimulus
            return EditStimulusMenu(title: "Stimulus")
        }
        option.deleteTexts = Flow.shared.deleteStimulusTexts(stimulus)
        option.delete = {
            Flow.shared.deleteStimulus(stimulus)
            return []
        }
        option.duplicate = {
            _ = Flow.shared.createAndSaveNewStimulus(from: stimulus)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewStimulus(sectionNumber: Int) {
        var option = Option(name: "+ new stimulus")
        option.style = .insert
        option.infoMessage = "To create a new stimulus."
        option.nextScreen = {
            if Flow.shared.createSaveAndSelectNewStimulus() {
                return EditStimulusMenu(title: "Stimulus")
            } else {
                return nil
            }
        }
        sections[sectionNumber].options.append(option)
    }
}
