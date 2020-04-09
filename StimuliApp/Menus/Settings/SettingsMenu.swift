//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class SettingsMenu: Menu {

    // MARK: - Setting
    override func setting() {
        backButton = ""

        sections = []
        makeSection0()
        makeSection1()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "User settings")
        sections.append(section)
        for property in Flow.shared.settings.userProperties {
            makeOption(from: property, sectionNumber: sectionNumber, defaultSettings: true)
        }
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Device settings")
        sections.append(section)
        for property in Flow.shared.settings.deviceProperties {
            makeOption(from: property, sectionNumber: sectionNumber, defaultSettings: true)
        }
    }
}
