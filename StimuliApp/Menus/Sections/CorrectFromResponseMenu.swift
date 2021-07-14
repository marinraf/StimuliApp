//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class CorrectFromResponseMenu: Menu {

    // MARK: - Setting
    override func setting() {
        sections = []
        makeSection0()
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Select response")
        sections.append(section)
        makeEmptyOption(sectionNumber: sectionNumber)
        for scene in Flow.shared.section.scenes {
            guard let response = FixedResponse(rawValue: scene.responseType.string) else { return }
            switch response {
            case .none:
                break
            case .leftRight, .topBottom, .keyboard, .keys, .touchObject, .lift:
                makeResponseValue(from: scene, sectionNumber: sectionNumber)
            case .touch, .path:
                makeResponsePosition(from: scene, sectionNumber: sectionNumber)
            case .moveObject:
                var values = false
                for property in scene.responseType.properties {
                    for newProperty in property.properties {
                        if let endPath = FixedEndPathValues(rawValue: newProperty.string) {
                            if endPath == .both {
                                values = true
                            }
                        }
                    }
                }
                if values {
                    makeResponseValues(from: scene, sectionNumber: sectionNumber)
                    makeResponsePosition(from: scene, sectionNumber: sectionNumber)
                } else {
                    makeResponseValue(from: scene, sectionNumber: sectionNumber)
                    makeResponsePosition(from: scene, sectionNumber: sectionNumber)
                }
            case .twoFingersTouch:
                makeResponsePosition2(from: scene, sectionNumber: sectionNumber)
            case .touchMultipleObjects:
                makeResponseValues(from: scene, sectionNumber: sectionNumber)
            }
        }
    }

    // MARK: - Options
    private func makeResponseValue(from scene: Scene, sectionNumber: Int) {
        let name = scene.name.string + "_responseValue"
        var option = Option(name: name)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.responseValue.somethingId = scene.id
            Flow.shared.section.responseValue.selectedValue = 0
            Flow.shared.section.responseValue.addProperties()
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeResponseValues(from scene: Scene, sectionNumber: Int) {
        let name = scene.name.string + "_responseValues"
        var option = Option(name: name)
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.responseValue.somethingId = scene.id
            Flow.shared.section.responseValue.selectedValue = 11
            Flow.shared.section.responseValue.addProperties()
            Flow.shared.section.responseValueVector = nil
            Flow.shared.section.responseValueDimension = nil

            if let scene = Flow.shared.section.responseValue.scene {
                for property in scene.responseType.properties where property.name == "endPath" {
                    for newProperty in property.properties {
                        if let value = FixedEndPathValues(rawValue: newProperty.string) {
                            switch value {
                            case .mobile, .stop:
                                Flow.shared.section.responseValueDimension = 1
                            case .both:
                                Flow.shared.section.responseValueDimension = 2
                            }
                        }
                    }
                }
            }

            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeResponsePosition(from scene: Scene, sectionNumber: Int) {
        let name = scene.name.string + "_responsePositionVector"
        var option = Option(name: name)
        option.nextScreen = {
            Flow.shared.section.responseValue.somethingId = scene.id
            Flow.shared.section.responseValue.selectedValue = 1
            Flow.shared.section.responseValue.addProperties()
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)

        for property in scene.responseType.properties {
            for newProperty in property.properties {
                if let value = FixedCorrect(rawValue: newProperty.name) {
                    let name = scene.name.string + "_response" + value.name.capitalizingFirstLetter()
                    if let selected = FixedCorrect.allCases.firstIndex(where: { $0 == value }) {
                        var option = Option(name: name)
                        option.nextScreen = {
                            Flow.shared.section.responseValue.somethingId = scene.id
                            Flow.shared.section.responseValue.selectedValue = selected
                            Flow.shared.section.responseValue.addProperties()
                            Flow.shared.saveTest(Flow.shared.test)
                            return nil
                        }
                        sections[sectionNumber].options.append(option)
                    }
                }
            }
        }
    }

    private func makeResponsePosition2(from scene: Scene, sectionNumber: Int) {
        
        var name0 = ""
        for property in scene.responseType.properties {
            for newProperty in property.properties {
                if ["module", "x", "y", "radius", "angle"].contains(newProperty.string) {
                    name0 = newProperty.string.capitalizingFirstLetter()
                }
            }
        }
        
        let name = scene.name.string + "_responseDistance" + name0
        if let selected = FixedCorrect.allCases.firstIndex(where: { $0.name == "distance" + name0 }) {
            var option = Option(name: name)
            option.style = .onlySelect
            option.nextScreen = {
                Flow.shared.section.responseValue.somethingId = scene.id
                Flow.shared.section.responseValue.selectedValue = selected
                Flow.shared.section.responseValue.addProperties()
                Flow.shared.saveTest(Flow.shared.test)
                return nil
            }
            sections[sectionNumber].options.append(option)
        }
    }

    private func makeEmptyOption(sectionNumber: Int) {
        var option = Option(name: "none")
        option.style = .onlySelect
        option.nextScreen = {
            Flow.shared.section.responseValue.somethingId = ""
            Flow.shared.section.responseValue.addProperties()
            Flow.shared.saveTest(Flow.shared.test)
            return nil
        }
        sections[sectionNumber].options.append(option)
    }
}
