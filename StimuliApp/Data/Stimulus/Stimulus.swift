//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Stimulus: Codable {

    var id: String
    var name: Property
    var order: Int

    var typeProperty: Property
    var activatedProperty: Property
    var shapeProperty: Property
    var startProperty: Property
    var durationProperty: Property
    var originProperty: Property
    var positionProperty: Property
    var rotationProperty: Property
    var borderProperty: Property
    var contrastProperty: Property
    var modulatorProperty: Property
    var noiseProperty: Property

    //empty
    init() {
        self.id = UUID().uuidString
        self.name = Property()
        self.order = 0

        self.typeProperty = Property()
        self.activatedProperty = Property()
        self.shapeProperty = Property()
        self.startProperty = Property()
        self.durationProperty = Property()
        self.originProperty = Property()
        self.positionProperty = Property()
        self.rotationProperty = Property()
        self.borderProperty = Property()
        self.contrastProperty = Property()
        self.modulatorProperty = Property()
        self.noiseProperty = Property()
    }

    //new
    init(name: String, order: Int) {
        self.id = UUID().uuidString
        self.name = StimulusData.makeNameProperty(text: name)
        self.order = order

        self.typeProperty = StimulusData.makeTypeProperty(type: .patch)
        self.activatedProperty = StimulusData.makeActivatedProperty(float: 1)
        self.shapeProperty = StimulusData.makeShapeProperty(shape: .rectangle)
        self.startProperty = StimulusData.makeStartProperty(float: 0)
        self.durationProperty = StimulusData.makeDurationProperty(float: 1000)
        self.originProperty = StimulusData.makeOriginProperty(selected: 0)
        self.positionProperty = StimulusData.makePositionProperty(selected: 0)
        self.rotationProperty = StimulusData.makeRotationProperty(float: 0)
        self.borderProperty = StimulusData.makeBorderProperty(selected: 0)
        self.contrastProperty = StimulusData.makeContrastProperty(selected: 0)
        self.modulatorProperty = StimulusData.makeModulatorProperty(selected: 0)
        self.noiseProperty = StimulusData.makeNoiseProperty(selected: 0)
    }

    //copy when duplicating stimulus
    init(from oldStimulus: Stimulus, name: String, order: Int) {
        self.id = UUID().uuidString
        self.name = StimulusData.makeNameProperty(text: name)
        self.order = order

        self.typeProperty = Property(from: oldStimulus.typeProperty)
        self.shapeProperty = Property(from: oldStimulus.shapeProperty)
        self.activatedProperty = Property(from: oldStimulus.activatedProperty)
        self.startProperty = Property(from: oldStimulus.startProperty)
        self.durationProperty = Property(from: oldStimulus.durationProperty)
        self.originProperty = Property(from: oldStimulus.originProperty)
        self.positionProperty = Property(from: oldStimulus.positionProperty)
        self.rotationProperty = Property(from: oldStimulus.rotationProperty)
        self.borderProperty = Property(from: oldStimulus.borderProperty)
        self.contrastProperty = Property(from: oldStimulus.contrastProperty)
        self.modulatorProperty = Property(from: oldStimulus.modulatorProperty)
        self.noiseProperty = Property(from: oldStimulus.noiseProperty)
    }

    var type: StimuliType {
        return StimuliType.allCases[typeProperty.selectedValue]
    }

    var shape: StimulusShape {
        return StimulusShape.allCases[shapeProperty.selectedValue]
    }

    var info: String {
        switch type {
        case .audio, .video, .pureTone, .text:
            return type.name
        default:
            return type.name + ", " + shape.name
        }
    }

    var allGeneralProperties: [Property] { //ordenadas como vienen de momento
        return [typeProperty, shapeProperty, activatedProperty, startProperty, durationProperty, originProperty,
                positionProperty, rotationProperty, borderProperty, contrastProperty, modulatorProperty, noiseProperty]
    }

    var allProperties: [Property] {
        var propertiesToReturn: [Property] = []
        for property in allGeneralProperties {
            propertiesToReturn += addProperties(property: property)
        }
        return propertiesToReturn
    }

    func addProperties(property: Property) -> [Property] {
        var propertiesToReturn: [Property] = [property]
        for newProperty in property.properties {
            propertiesToReturn += addProperties(property: newProperty)
        }
        return propertiesToReturn
    }
}
