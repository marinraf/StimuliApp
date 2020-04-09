//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditStimulusMenu: Menu {

    var regular: Bool = true

    // MARK: - Setting
    override func setting() {
        buttonImage = "preview stimulus"
        title2 = Flow.shared.stimulus.name.string
        backButton = "< Stimuli"

        let extra: [StimuliType] = [.text, .video, .audio, .pureTone]
        if extra.contains(Flow.shared.stimulus.type) {
            regular = false
        } else {
            regular = true
        }

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
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Stimulus name")
        section.dependency = Flow.shared.stimulus.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.stimulus.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.test.stimuli.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Stimulus type")
        section.dependency = Flow.shared.stimulus.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.stimulus.typeProperty, sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        if regular {
            let section = MenuSection(title: "Shape and size")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.shapeProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "Duration")
        section.dependency = Flow.shared.stimulus.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.stimulus.activatedProperty, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.stimulus.startProperty, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.stimulus.durationProperty, sectionNumber: sectionNumber)
    }

    private func makeSection4() {
        let sectionNumber = 4
        if regular {
            let section = MenuSection(title: "Position")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.originProperty, sectionNumber: sectionNumber)
            makeOption(from: Flow.shared.stimulus.positionProperty, sectionNumber: sectionNumber)
            makeOption(from: Flow.shared.stimulus.rotationProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }

    private func makeSection5() {
        let sectionNumber = 5
        if regular {
            let section = MenuSection(title: "Border")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.borderProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }

    private func makeSection6() {
        let sectionNumber = 6
        if regular {
            let section = MenuSection(title: "Contrast")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.contrastProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }

    private func makeSection7() {
        let sectionNumber = 7
        if regular {
            let section = MenuSection(title: "Noise")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.noiseProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }

    private func makeSection8() {
        let sectionNumber = 8
        if regular {
            let section = MenuSection(title: "Modulator of contrast")
            section.dependency = Flow.shared.stimulus.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)
            makeOption(from: Flow.shared.stimulus.modulatorProperty, sectionNumber: sectionNumber)
        } else {
            sections.append(MenuSection(title: ""))
        }
    }
}
