//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Object: Codable {

    var id: String
    var name: Property
    var order: Int

    var sceneId: String
    var stimulusId: String

    var variables: [Variable]

    //empty
    init() {
        self.id = UUID().uuidString
        self.name = Property()
        self.order = 0

        self.sceneId = ""
        self.stimulusId = ""
        self.variables = []
    }

    //new object
    init(name: String, stimulus: Stimulus, scene: Scene, order: Int) {
        self.id = UUID().uuidString
        self.name = ObjectData.makeNameProperty(text: name)
        self.order = order

        self.sceneId = scene.id
        self.stimulusId = stimulus.id

        self.variables = []

        createVariables()
    }

    //copy when duplicating scene
    init(from oldObject: Object, name: String) {
        self.id = UUID().uuidString
        self.name = ObjectData.makeNameProperty(text: name)
        self.order = oldObject.order

        self.sceneId = oldObject.sceneId
        self.stimulusId = oldObject.stimulusId
        self.variables = []

        for element in oldObject.variables {
            self.variables.append(Variable(from: element, object: self))
        }
    }

    //copy when duplicating section
    init(from oldObject: Object, name: String, scene: Scene) {
        self.id = UUID().uuidString
        self.name = ObjectData.makeNameProperty(text: name)
        self.order = oldObject.order

        self.sceneId = scene.id
        self.stimulusId = oldObject.stimulusId
        self.variables = []

        for element in oldObject.variables {
            self.variables.append(Variable(from: element, object: self))
        }
    }

    var scene: Scene? {
        return Flow.shared.test.scenes.first(where: { $0.id == sceneId })
    }

    var stimulus: Stimulus? {
        return Flow.shared.test.stimuli.first(where: { $0.id == stimulusId })
    }

    var section: Section? {
        return self.scene?.section
    }

    var info: String {
        let name = stimulus?.name.string ?? ""
        let type = stimulus?.info ?? ""
        if name == "" && type == "" {
            return ""
        } else {
            return name + ": " + type
        }
    }

    var stimulusProperty: Property {
        return ObjectData.makeStimulusProperty(text: stimulus?.name.string ?? "")
    }

    var type: StimuliType? {
        return stimulus?.type
    }

    var shape: StimulusShape? {
        return stimulus?.shape
    }

    var typeProperty: Property {
        return ObjectData.makeTypeProperty(text: stimulus?.type.name ?? "")
    }

    var shapeProperty: Property {
        return ObjectData.makeShapeProperty(text: stimulus?.shape.name ?? "")
    }

    private func createVariables() {
        guard let stimulus = self.stimulus else { return }

        for property in stimulus.allProperties where property.timeDependency == .variable {
            addVariable(from: property)
        }
    }

    func addVariable(from property: Property) {
        let newVariable = Variable(objectId: self.id,
                                   propertyId: property.id)

        self.variables.append(newVariable)
    }
}
