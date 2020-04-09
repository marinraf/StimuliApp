//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct TestData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.testName,
                        text: text)
    }

    static func makeFrameRateProperty(frameRate: Int, selectedValue: Int) -> Property {
        if frameRate > 100 {
            return  Property(name: "frameRate",
                             info: Texts.frameRate,
                             propertyType: .select,
                             unitType: .decimal,
                             fixedValues: ["60 Hz", "120 Hz"],
                             selectedValue: selectedValue)
        } else {
            let frameProperty = Property(name: "frameRate",
                                    info: Texts.frameRate2,
                                    propertyType: .select,
                                    unitType: .decimal,
                                    fixedValues: ["60 Hz"],
                                    selectedValue: 0)
            frameProperty.onlyInfo = true
            return frameProperty
        }
    }

    static func makeBrightnessProperty(float: Float) -> Property {
        return Property(name: "brightness",
                        info: Texts.brightness,
                        propertyType: .simpleFloat,
                        unitType: .valueFrom0to1,
                        float: float)
    }

    static func makeGammaProperty(selected: Int) -> Property {
        return Property(name: "gamma",
                        info: Texts.gamma,
                        propertyType: .gamma,
                        unitType: .decimal,
                        fixedValues: FixedGamma.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeDistanceProperty(selected: Int) -> Property {
        let property = Property(name: "viewingDistance",
                                info: Texts.viewingDistance,
                                propertyType: .distance,
                                unitType: .decimal,
                                fixedValues: FixedDistance.allCases.map({ $0.name }),
                                selectedValue: selected)
        property.float = Constants.defaultDistanceCm
        return property
    }

    static func makeCancelProperty(selected: Int) -> Property {
        return Property(name: "XButton",
                        info: Texts.XButton,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedXButton.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeRandomnessProperty(selected: Int) -> Property {
        return Property(name: "randomness",
                        info: Texts.randomness,
                        propertyType: .randomness,
                        unitType: .decimal,
                        fixedValues: FixedRandomness.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeFirstSectionProperty() -> Property {
        return Property(name: "firstSection",
                        info: Texts.firstSection,
                        text: "none")
    }

    static func addPropertiesToRandomness(property: Property) {

        property.properties = []

        guard let selected = FixedRandomness(rawValue: property.string) else { return }
        switch selected {
        case .automaticRandomness:
            break
        case .withSeedsRandomness:
            for section in Flow.shared.test.sections where section.isShuffled {
                let sectionProperty = makePropertyToAddToRandomness(name: section.id)
                property.properties.append(sectionProperty)
            }
            for listOfValues in Flow.shared.test.listsOfValues where
                (listOfValues.isShuffled || listOfValues.isRandomBlock) {
                let listProperty = makePropertyToAddToRandomness(name: listOfValues.id)
                property.properties.append(listProperty)
            }
        }
    }

    static func addPropertiesToDistance(property: Property) {

        if property.properties.isEmpty {
            let distance = Property(name: "distanceValue",
                                    info: Texts.distanceValue,
                                    propertyType: .simpleFloat,
                                    unitType: .externalSize,
                                    float: Constants.defaultDistanceCm)
            property.properties.append(distance)
        } else if let distanceType = FixedDistance(rawValue: property.string) {
            if distanceType == .constant {
                property.properties[0].name = "distanceValue"
                property.properties[0].info = Texts.distanceValue
            } else {
                property.properties[0].name = "distanceDefault"
                property.properties[0].info = Texts.distanceDefault
            }
        }
    }

    static func makePropertyToAddToRandomness(name: String) -> Property {
        let property = Property(name: name,
                                info: Texts.randomness,
                                propertyType: .select,
                                unitType: .decimal,
                                fixedValues: FixedRandomness.allCases.map({ $0.name }),
                                selectedValue: 0)
        property.somethingId = name
        return property
    }

    static func addPropertiesToGamma(property: Property) {

        property.properties = []

        guard let gammaType = FixedGamma(rawValue: property.string) else { return }
        guard gammaType == .calibrated else { return }

        let newProperty = Property(name: "gammaValue",
                                   info: Texts.gammaValue,
                                   propertyType: .simpleFloat,
                                   unitType: .variableUnit,
                                   float: 2.2)

        property.properties.append(newProperty)
    }
}

enum FixedGamma: String, Codable, CaseIterable {

    case linear
    case normal
    case calibrated

    var description: String {
        switch self {
        case .linear:
            return Texts.linear
        case .normal:
            return Texts.normal
        case .calibrated:
            return Texts.calibrated
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedXButton: String, Codable, CaseIterable {

    case topLeft = "top left"
    case topRight = "top right"
    case bottomLeft = "bottom left"
    case bottomRight = "bottom right"
    case noButton = "no button"

    var name: String {
        return self.rawValue
    }
}

enum FixedDistance: String, Codable, CaseIterable {

    case constant = "constant"
    case dependent = "set each time"

    var description: String {
        switch self {
        case .constant:
            return Texts.constant
        case .dependent:
            return Texts.dependent
        }
    }

    var name: String {
        return self.rawValue
    }
}

enum FixedRandomness: String, Codable, CaseIterable {

    case automaticRandomness = "automatically generated"
    case withSeedsRandomness = "generated with seeds"

    var description: String {
        switch self {
        case .automaticRandomness:
            return Texts.automaticRandomness
        case .withSeedsRandomness:
            return Texts.withSeedsRandomness
        }
    }

    var name: String {
        return self.rawValue
    }
}
