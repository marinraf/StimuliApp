//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditTestMenu: Menu {

    // MARK: - Setting
    override func setting() {
        buttonImage = "preview test"
        export = true
        title2 = Flow.shared.test.name.string

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Test name")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        makeOption(from: Flow.shared.test.name,
                     sectionNumber: sectionNumber,
                     badNames: Flow.shared.tests.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Test settings")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        makeOption(from: Flow.shared.test.frameRate, sectionNumber: sectionNumber)

        var shouldUseMacConfiguration = false
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                shouldUseMacConfiguration = true
            }
        }
        if !shouldUseMacConfiguration {
            makeOption(from: Flow.shared.test.brightness, sectionNumber: sectionNumber)
        }
        makeOption(from: Flow.shared.test.gamma, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.cancelButtonPosition, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.test.randomness, sectionNumber: sectionNumber)
        
        makeOption(from: Flow.shared.test.distance, sectionNumber: sectionNumber)
        
        if Flow.shared.test.eyeTracker == nil {
            Flow.shared.test.eyeTracker = TestData.makeEyeTrackerProperty(fixedValues: Flow.shared.possibleEyeTrackers, value: "off")
        }
        
        if let tracker = Flow.shared.test.eyeTracker {
            makeOption(from: tracker, sectionNumber: sectionNumber)
        }
        
        if Flow.shared.test.neon == nil {
            Flow.shared.test.neon = TestData.makeNeonProperty(selected: 0)
        }
        
        if let neon = Flow.shared.test.neon {
            makeOption(from: neon, sectionNumber: sectionNumber)
        }
        
        if Flow.shared.test.markers == nil {
            Flow.shared.test.markers = TestData.makeMarkersProperty(selected: 0)
        }
        
        if let markers = Flow.shared.test.markers {
            makeOption(from: markers, sectionNumber: sectionNumber)
        }
        
        if Flow.shared.test.longAudios == nil {
            Flow.shared.test.longAudios = TestData.makeLongAudiosProperty(selected: 0)
        }
        
        if let longAudios = Flow.shared.test.longAudios {
            makeOption(from: longAudios, sectionNumber: sectionNumber)
        }
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "First section")
        section.dependency = Flow.shared.test.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeFirstSection(sectionNumber: sectionNumber)
    }

    private func makeFirstSection(sectionNumber: Int) {
        let firstSection = Flow.shared.test.firstSection
        var option = Option(name: firstSection.name + ":")
        if firstSection.somethingId == "" {
            option.detail = firstSection.text
        } else {
            option.detail = firstSection.nameToShow
        }
        option.infoMessage = firstSection.info
        option.nextScreen = {
            Flow.shared.property = firstSection
            return SelectFirstSectionMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }
}
