//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

enum StimulusShape: String, Codable, CaseIterable {

    case rectangle
    case ellipse
    case cross
    case polygon
    case ring
    case wedge

    var description: String {
        switch self {
        case .rectangle:
            return "Rectangle or square shape."
        case .ellipse:
            return "Ellipse or circle shape."
        case .cross:
            return "Cross shape."
        case .polygon:
            return "Polygon (3 to 10 sides) shape."
        case .ring:
            return "Ring shape."
        case .wedge:
            return "Wedge shape."
        }
    }

    var name: String {
        return self.rawValue
    }
}

extension StimulusData {

    static func addPropertiesToType(property: Property) {

        property.properties = []
        let type = StimuliType(rawValue: property.string) ?? .patch
        property.properties += type.typeProperties
    }

    static func addPropertiesToTimeFunction(property: Property) {

        property.properties = []

        if property.timeDependency == .timeDependent {
            property.properties = property.timeFunction.timeFunProperties(for: property)
        }
    }

    static func addPropertiesToShape(property: Property) {

        property.properties = []

        let size = Property(name: "size",
                            info: "The size of the shape containing the stimulus.",
                            propertyType: .size2d,
                            unitType: .size,
                            fixedValues: FixedSize2d.allCases.map({ $0.name }),
                            selectedValue: 0,
                            float: 300)

        switch property.selectedValue {
        case 0: //rectangle
            property.properties.append(size)
        case 1: //ellipse
            property.properties.append(size)
        case 2: //cross
            let length = Property(name: "length",
                                  info: "The length of the cross sides.",
                                  propertyType: .timeFloat,
                                  unitType: .size,
                                  float: 100)

            let thickness = Property(name: "thickness",
                                     info: "The thickness of the cross strokes.",
                                     propertyType: .timeFloat,
                                     unitType: .size,
                                     float: 8)

            property.properties.append(length)
            property.properties.append(thickness)
        case 3: //polygon
            let diameterSize = Property(name: "diameterSize",
                                        info: "The diameter of the circumscribed circle of the polygon.",
                                        propertyType: .timeFloat,
                                        unitType: .size,
                                        float: 300)

            let sides = Property(name: "sides",
                                 info: "The number of sides of the polygon.",
                                 propertyType: .timeFloat,
                                 unitType: .valueFrom3to10,
                                 float: 3)

            property.properties.append(diameterSize)
            property.properties.append(sides)
        case 4: //ring
            let diameter = Property(name: "exteriorDiameter",
                                    info: "The exterior diameter of the ring.",
                                    propertyType: .timeFloat,
                                    unitType: .size,
                                    float: 300)

            let interiorDiameter = Property(name: "interiorDiameter",
                                            info: "The interior diameter of the ring.",
                                            propertyType: .timeFloat,
                                            unitType: .size,
                                            float: 100)

            property.properties.append(diameter)
            property.properties.append(interiorDiameter)
        case 5: //wedge
            let diameter = Property(name: "diameter",
                                    info: "The diameter of the circle the wedge is part of.",
                                    propertyType: .timeFloat,
                                    unitType: .size,
                                    float: 300)

            let angleSize = Property(name: "angleSize",
                                     info: "The angle size of the wedge.",
                                     propertyType: .timeFloat,
                                     unitType: .angle,
                                     float: 0.7854)

            property.properties.append(diameter)
            property.properties.append(angleSize)
        default:
            property.properties.append(size)
        }
    }
}
