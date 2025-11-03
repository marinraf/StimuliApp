//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct TestData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.testName,
                        text: text)
    }

    static func makeFrameRateProperty(frameRate: Int, selected: Int) -> Property {
        if frameRate > 100 {
            return  Property(name: "frameRate",
                             info: Texts.frameRate,
                             propertyType: .select,
                             unitType: .decimal,
                             fixedValues: ["60 Hz", "120 Hz"],
                             selectedValue: selected)
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
        return Property(name: "luminance",
                        info: Texts.brightness,
                        propertyType: .simpleFloat,
                        unitType: .brightness,
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

    static func makeEyeTrackerProperty(selected: Int) -> Property {
        return Property(name: "measureViewingDistance",
                        info: Texts.eyeTracker,
                        propertyType: .testEyeTracker,
                        unitType: .decimal,
                        fixedValues: Flow.shared.possibleEyeTrackers,
                        selectedValue: selected)
    }
    
    static func makeNeonProperty(selected: Int) -> Property {
        return Property(name: "neonEyeTrackerSync",
                        info: Texts.neonEyeTracker,
                        propertyType: .neon,
                        unitType: .decimal,
                        fixedValues: FixedNeon.allCases.map({ $0.name }),
                        selectedValue: selected)
    }
    
    static func makeLongAudiosProperty(selected: Int) -> Property {
        return Property(name: "longAudios",
                        info: Texts.longAudios,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: ["off", "on"],
                        selectedValue: selected)
    }

    static func makeDistanceProperty(selected: Int) -> Property {
        let property = Property(name: "expectedViewingDistance",
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

    static func addPropertiesToPositionEyeTracker(property: Property) {

        property.properties = []

        guard let selected = FixedPositionEyeTracker(rawValue: property.string) else { return }
        switch selected {
        case .cartesian:
            let propertyX = Property(name: property.name + "X",
                                     info: "Horizontal position.",
                                     propertyType: .select,
                                     unitType: .decimal,
                                     fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                     selectedValue: 0)
            let propertyY = Property(name: property.name + "Y",
                                     info: "Vertical position.",
                                     propertyType: .select,
                                     unitType: .decimal,
                                     fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                     selectedValue: 0)
            property.properties.append(propertyX)
            property.properties.append(propertyY)
        case .polar:
            let propertyRadius = Property(name: property.name + "Radius",
                                          info: "Radius position.",
                                          propertyType: .select,
                                          unitType: .decimal,
                                          fixedValues: UnitType.size.possibleUnits.map({ $0.name }),
                                          selectedValue: 0)
            let propertyAngle = Property(name: property.name + "Angle",
                                         info: "Angle position.",
                                         propertyType: .select,
                                         unitType: .decimal,
                                         fixedValues: UnitType.angle.possibleUnits.map({ $0.name }),
                                         selectedValue: 0)
            property.properties.append(propertyRadius)
            property.properties.append(propertyAngle)
        }
    }


    static func addPropertiesToEyeTracker(property: Property) {
        
        property.properties = []
        
        let selected = property.string
        
        if selected == "using SeeSo" {
            let position = Property(name: "position",
                                    info: """
                                    The response position, measured in cartesian or polar variables.
                                    """,
                                    propertyType: .positionEyeTracker,
                                    unitType: .decimal,
                                    fixedValues: FixedPositionEyeTracker.allCases.map({ $0.name }),
                                    selectedValue: 0)
            
            property.properties.append(position)
        }
    }
    
    static func addPropertiesToNeon(property: Property) {
        
        property.properties = []
        
        let selected = property.string
        
        if selected == "on" {
            
            let ip = Property(name: "IP",
                              info: """
                                The IP address assigned to the Neon eye tracker within the local network.
                                """,
                              text: "192.168.1.1")
            
            let markers = Property(name: "useMarkers",
                                   info: """
                               Enables the display of reference markers (one at each corner of the screen) \
                               during the test. These markers allow the Neon eye tracker to map the screen \
                               position accurately within the environment.
                               """,
                                   propertyType: .select,
                                   unitType: .decimal,
                                   fixedValues: ["off", "on"],
                                   selectedValue: 0)
            
            property.properties.append(ip)
            property.properties.append(markers)
        }
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

enum FixedNeon: String, Codable, CaseIterable {
    
    case off = "off"
    case on = "on"
    
    var description: String {
        switch self {
        case .off:
            return "off"
        case .on:
            return "on"
        }
    }
    
    var name: String {
        return self.rawValue
    }
}


enum FixedPositionEyeTracker: String, Codable, CaseIterable {

    case cartesian = "cartesian vars"
    case polar = "polar vars"

    var description: String {
        switch self {
        case .cartesian:
            return "Two independent cartesian variables."
        case .polar:
            return "Two independent polar variables."
        }
    }

    var name: String {
        return self.rawValue
    }
}
