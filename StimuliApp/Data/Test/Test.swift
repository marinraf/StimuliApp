//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Test: NSObject, Codable {

    var id: String
    var name: Property
    var order: Int
    var frameRate: Property
    var brightness: Property
    var gamma: Property
    var distance: Property
    var cancelButtonPosition: Property
    var randomness: Property
    var firstSection: Property
    var stimuli: [Stimulus]
    var sections: [Section]
    var listsOfValues: [ListOfValues]
    var collapse: [String: Bool]
    var files: [String]
    var screenWidth: Float?
    var screenHeight: Float?

    override init() {
        id = UUID().uuidString
        name = Property()
        order = 0
        frameRate = Property()
        brightness = Property()
        gamma = Property()
        distance = Property()
        cancelButtonPosition = Property()
        randomness = Property()
        firstSection = Property()
        stimuli = []
        sections = []
        listsOfValues = []
        collapse = [:]
        files = []
        screenWidth = nil
        screenHeight = nil
    }

    //new test
    init(name: String, order: Int) {
        self.id = UUID().uuidString
        self.order = order

        self.name = TestData.makeNameProperty(text: name)
        self.frameRate = TestData.makeFrameRateProperty(frameRate: Flow.shared.settings.maximumFrameRate,
                                                        selectedValue: 0)
        self.brightness = TestData.makeBrightnessProperty(float: 0.7)
        self.gamma = TestData.makeGammaProperty(selected: 0)
        self.distance = TestData.makeDistanceProperty(selected: 0)
        self.cancelButtonPosition = TestData.makeCancelProperty(selected: 0)
        self.randomness = TestData.makeRandomnessProperty(selected: 0)
        self.firstSection = TestData.makeFirstSectionProperty()

        self.stimuli = []
        self.sections = []
        self.listsOfValues = []
        self.collapse = [:]
        self.files = []

        self.screenWidth = Flow.shared.settings.width
        self.screenHeight = Flow.shared.settings.height
    }

    var scenes: [Scene] {
        return self.sections.flatMap({ $0.scenes })
    }

    var objects: [Object] {
        return self.scenes.flatMap({ $0.objects })
    }

    var variables: [Variable] {
        return self.objects.flatMap({ $0.variables })
    }

    var stimuliProperties: [Property] {
        return self.stimuli.flatMap({ $0.allProperties })
    }

    var sectionValueProperties: [Property] {
        return self.sections.map({ $0.trialValue })
    }

    var sceneColorProperties: [Property] {
        var properties: [Property] = []
        for scene in self.scenes {
            properties.append(scene.color)
            for property in scene.color.allProperties {
                properties.append(property)
            }
        }
        return properties
    }

    var allProperties: [Property] {
        return sceneColorProperties + stimuliProperties + sectionValueProperties
    }

    func saveSection(_ section: Menu.MenuSection) -> Bool {
        if let value = collapse[section.reference] {
            return value
        } else {
            collapse[section.reference] = false
            return false
        }
    }

    func toogleSection(_ section: Menu.MenuSection) {
        if let value = collapse[section.reference] {
            collapse[section.reference] = !value
        }
        Flow.shared.saveTest(self)
    }

    func changeAllVisualDegrees(newDistanceCm: Float, oldDistanceCm: Float) {
        for stimulus in stimuli {
            for property in stimulus.allProperties where property.unit == .visualAngleDegree {
                property.float = property.float * newDistanceCm / oldDistanceCm
            }
        }
        Flow.shared.saveTest(Flow.shared.test)
    }
}
