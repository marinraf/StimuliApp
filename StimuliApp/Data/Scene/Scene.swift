//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Scene: Codable {

    var id: String
    var name: Property
    var order: Int

    var sectionId: String

    var color: Property
    var numberOfLayers: Property
    var continuousResolution: Property
    var responseType: Property
    var durationType: Property
    var gazeFixation: Property?
    var distanceFixation: Property?
    var distanceInScreen: Property?
    var objects: [Object]

    //empty
    init() {
        self.id = UUID().uuidString
        self.name = Property()
        self.order = 0

        self.sectionId = ""

        self.color = Property()
        self.numberOfLayers = Property()
        self.continuousResolution = Property()
        self.gazeFixation = Property()
        self.distanceFixation = Property()
        self.distanceInScreen = Property()
        self.responseType = Property()
        self.durationType = Property()
        self.objects = []
    }

    //new
    init(name: String, sectionId: String, order: Int) {
        self.id = UUID().uuidString
        self.name = SceneData.makeNameProperty(text: name)
        self.order = order

        self.sectionId = sectionId

        self.color = StimulusData.createProperty(name: "color",
                                                 info: "Color of the background.",
                                                 measure: .color,
                                                 value: 0.5)
        self.color.somethingId = self.id

        self.numberOfLayers = SceneData.makeNumberOfLayersProperty(selected: 0)
        self.continuousResolution = SceneData.makeContinuousResolutionProperty(selected: 0)
        self.gazeFixation = SceneData.makeSceneFixationProperty(selected: 0)
        self.distanceFixation = SceneData.makeSceneDistanceMeasureProperty(selected: 0)
        self.distanceInScreen = SceneData.makeSceneDistanceInScreenProperty(selected: 0)
        self.responseType = SceneData.makeResponseProperty(selected: 0)
        self.durationType = SceneData.makeDurationProperty(selected: 0)
        self.objects = [SceneData.makeBackground(id: self.id)]
    }

    //copy when duplicating scene or duplicating section
    init(from oldScene: Scene, sectionId: String, name: String, order: Int) {
        self.id = UUID().uuidString
        self.name = SceneData.makeNameProperty(text: name)
        self.order = order

        self.sectionId = sectionId

        self.color = Property(from: oldScene.color)
        self.color.somethingId = self.id
        self.numberOfLayers = Property(from: oldScene.numberOfLayers)
        self.continuousResolution = Property(from: oldScene.continuousResolution)
        if let fix = oldScene.gazeFixation {
            self.gazeFixation = Property(from: fix)
        } else {
            self.gazeFixation = SceneData.makeSceneFixationProperty(selected: 0)
        }
        if let dis = oldScene.distanceFixation {
            self.distanceFixation = Property(from: dis)
        } else {
            self.distanceFixation = SceneData.makeSceneDistanceMeasureProperty(selected: 0)
        }
        if let screen = oldScene.distanceInScreen {
            self.distanceInScreen = Property(from: screen)
        } else {
            self.distanceInScreen = SceneData.makeSceneDistanceInScreenProperty(selected: 0)
        }
        self.responseType = Property(from: oldScene.responseType)
        self.durationType = Property(from: oldScene.durationType)
        self.objects = []
        self.objects = oldScene.objects.map({ Object(from: $0, name: $0.name.string, scene: self) })

        let oldObjectsId = oldScene.objects.map({ $0.id })
        let newObjectsId = self.objects.map({ $0.id })

        for property in self.responseType.properties {
            if let i = oldObjectsId.firstIndex(of: property.somethingId) {
                property.somethingId = newObjectsId[i]
            }
        }

        let oldColorPropertiesId = [oldScene.color.id] + oldScene.color.allProperties.map({ $0.id })
        let newColorPropertiesId = [self.color.id] + self.color.allProperties.map({ $0.id })

        for variable in self.objects[0].variables {
            if let i = oldColorPropertiesId.firstIndex(of: variable.propertyId) {
                variable.propertyId = newColorPropertiesId[i]
            }

        }
    }

    var variables: [Variable] {
        return objects.flatMap({ $0.variables })
    }

    var section: Section? {
        return Flow.shared.test.sections.first(where: { $0.id == sectionId })
    }

    var movableObjects: [Object] {
        var objectsToReturn: [Object] = []
        for object in objects {
            if let metal = object.type?.metal {
                if metal {
                    objectsToReturn.append(object)
                }
            }
        }
        return objectsToReturn
    }
}
