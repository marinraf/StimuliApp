//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditSceneMenu: Menu {

    var deleting = false

    var extraSection = 0

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.scene.name.string
        backButton = "< Section:  \(Flow.shared.section.name.string)"
        buttonImage = "preview scene"

        sections = []
        extraSection = 0
        makeSection0()
        makeSection1()
        makeSection2()
        makeSection3()
        makeSection4()
        makeSection5()
        makeSection6()

    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveObjects(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "Scene name")
        section.dependency = Flow.shared.scene.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.scene.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.section.scenes.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Scene duration")
        section.dependency = Flow.shared.scene.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.scene.durationType, sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "Scene response")
        section.dependency = Flow.shared.scene.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.scene.responseType, sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "Background and layers")
        section.dependency = Flow.shared.scene.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.scene.color, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.scene.numberOfLayers, sectionNumber: sectionNumber)
        makeOption(from: Flow.shared.scene.continuousResolution, sectionNumber: sectionNumber)
    }

    private func makeSection4() {
        let sectionNumber = 4
        var sectionTitle = ""
        
        if (Flow.shared.isAvailableSeeSo && Flow.shared.test.eyeTracker?.string == "using SeeSo") ||
            (Flow.shared.isAvailableARKit && Flow.shared.test.eyeTracker?.string == "using ARKit") {
    
            extraSection = 1
            sectionTitle = sectionTitle + "UserDistance control"
            let section = MenuSection(title: sectionTitle)
            section.dependency = Flow.shared.scene.id
            section.collapsed = Flow.shared.test.saveSection(section)
            sections.append(section)

            if Flow.shared.isAvailableSeeSo && Flow.shared.test.eyeTracker?.string == "using SeeSo" {
                if Flow.shared.scene.gazeFixation == nil {
                    Flow.shared.scene.gazeFixation = SceneData.makeSceneFixationProperty(selected: 0)
                }
                if let fix = Flow.shared.scene.gazeFixation {
                    makeOption(from: fix, sectionNumber: sectionNumber)
                }
            }
            
            if Flow.shared.scene.distanceFixation == nil {
                Flow.shared.scene.distanceFixation = SceneData.makeSceneDistanceMeasureProperty(selected: 0)
            }
            if let dis = Flow.shared.scene.distanceFixation {
                makeOption(from: dis, sectionNumber: sectionNumber)
            }
            if Flow.shared.scene.distanceInScreen == nil {
                Flow.shared.scene.distanceInScreen = SceneData.makeSceneDistanceInScreenProperty(selected: 0)
            }
            if let dis = Flow.shared.scene.distanceInScreen {
                makeOption(from: dis, sectionNumber: sectionNumber)
            }
        }
    }

    private func makeSection5() {
        let sectionNumber = 4 + extraSection
        let section = MenuSection(title: "Objects")
        section.dependency = Flow.shared.scene.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)

        for object in Flow.shared.scene.objects {
            if object.order == 0 {
                makeObjectBackgrounde(from: object, sectionNumber: sectionNumber)
            } else {
                makeObject(from: object, sectionNumber: sectionNumber)
            }
        }
    }

    private func makeSection6() {
        let sectionNumber = 5 + extraSection
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed
        sections.append(section)
        makeNewObject(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func makeObject(from object: Object, sectionNumber: Int) {
        var option = Option(name: object.name.string + ":")
        option.detail = object.info
        option.style = .optional
        option.canDuplicate = true
        option.infoMessage = Texts.object
        option.nextScreen = {
            Flow.shared.object = object
            return EditObjectMenu(title: "Object")
        }
        option.deleteTexts = Flow.shared.deleteObjectTexts()
        option.delete = { [weak self] in
            var indices: [IndexPath] = []
            if let sectionToUse = self?.sections[sectionNumber - 2] {
                for (index, option) in sectionToUse.options.enumerated() {
                    if option.name == object.name.string + ":" || option.name == object.name.string + "Value:" {
                        let indexPath = IndexPath(row: index, section: sectionNumber - 2)
                        indices += [indexPath]
                    }
                }
            }
            Flow.shared.deleteObject(object)
            return indices
        }
        option.duplicate = { [weak self] in
            var indices: [IndexPath] = []
            if let sectionToUse = self?.sections[sectionNumber - 2] {
                for (index, option) in sectionToUse.options.enumerated() {
                    if option.name == object.name.string + ":" {
                        let indexPath = IndexPath(row: index + 1, section: sectionNumber - 2)
                        indices += [indexPath]
                    } else if option.name == object.name.string + "Value:" {
                        if let newIndexPath = indices.last {
                            indices.removeLast()
                            let newNewIndexPath = IndexPath(row: newIndexPath.row + 1, section: newIndexPath.section)
                            indices += [newNewIndexPath]
                        }
                    }
                }
            }
            _ = Flow.shared.createAndSaveNewObject(from: object)
            return indices
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeObjectBackgrounde(from object: Object, sectionNumber: Int) {
        var option = Option(name: object.name.string)
        option.detail = object.info
        option.style = .onlyInfo
        option.infoMessage = Texts.backgroundColor
        sections[sectionNumber].options.append(option)
    }

    private func makeNewObject(sectionNumber: Int) {
        var option = Option(name: "+ new object")
        option.style = .insert
        option.infoMessage = Texts.newObject
        option.nextScreen = {
            return ObjectFromStimulusMenu(title: "", style: .select)
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeColor(sectionNumber: Int) {
        makeOption(from: Flow.shared.scene.color, sectionNumber: sectionNumber)
    }
}
