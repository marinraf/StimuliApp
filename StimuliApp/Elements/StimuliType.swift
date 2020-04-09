//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation



enum StimuliType: String, Codable, CaseIterable {

    case patch
    case gradient
    case grating
    case checkerboard
    case radialCheckerboard
    case dots
    case image
    case text
    case video
    case audio
    case pureTone

    var style: StimuliStyle {
        switch self {
        case .dots: return .dots
        case .image: return .image
        case .text: return .nonMetal
        case .video: return .nonMetal
        case .audio: return .nonMetal
        case .pureTone: return .nonMetal
        default: return .metalRegular
        }
    }





    //patch
    var patchName: String {
        return "Patch with uniform color."
    }

    func createPatch() -> [Property] {

        let colorInfo = "Color of the patch."
        let color = createProperty(name: "color",
                                   info: colorInfo,
                                   measure: .color,
                                   value: 0)

        return [color]
    }





    //gradient
    var gradientName: String {
        return "Patch with gradient color. Changing linearly from color1 to color2 for the size of the gradient."
    }

    func createGradient() -> [Property] {

        let gradientSizeInfo = """
        The size of the gradient.
        It is defined as the distance from the position with color = color1 to the position with color = color2.
        """
        let gradientSize = createProperty(name: "gradientSize",
                                          info: gradientSizeInfo,
                                          measure: .size,
                                          value: 300)

        let color1Info = "First color."
        let color1 = createProperty(name: "color1",
                                    info: color1Info,
                                    measure: .color,
                                    value: 0)

        let color2Info = "Second color."
        let color2 = createProperty(name: "color2",
                                    info: color2Info,
                                    measure: .color,
                                    value: 1)

        let gradientPositionInfo =  """
        Position of the center of the gradient relative to the center of the shape that contains it.
        Measured in the direction of the gradient set by the gradientRotation.
        """
        let gradientPosition = createProperty(name: "gradientPosition",
                                          info: gradientPositionInfo,
                                          measure: .size,
                                          value: 0)

        let gradientRotationInfo = """
        Orientation of the gradient. This property only rotates the gradient but not the shape that masks it.
        """
        let gradientRotation = createProperty(name: "gradientRotation",
                                              info: gradientRotationInfo,
                                              measure: .angle,
                                              value: 0)

        return [gradientSize, color1, color2, gradientPosition, gradientRotation]
    }





    //grating
    var gratingName: String {
        return """
        Grating with color sinusoidally oscillating from color1 to color2.
        """
    }

    func createGrating() -> [Property] {

        let periodInfo = "Size period of the sinusoidal function."
        let period = createProperty(name: "period",
                                    info: periodInfo,
                                    measure: .size,
                                    value: 100)

        let color1Info = "First color."
        let color1 = createProperty(name: "color1",
                                    info: color1Info,
                                    measure: .color,
                                    value: 0)

        let color2Info = "Second color."
        let color2 = createProperty(name: "color2",
                                    info: color2Info,
                                    measure: .color,
                                    value: 1)

        let phaseInfo = "Phase of the sinusoidal function."
        let phase = createProperty(name: "phase",
                                   info: phaseInfo,
                                   measure: .angle,
                                   value: 0)

        let gratingRotationInfo = """
        Orientation of the grating. This property only rotates the grating but not the shape that masks it.
        """
        let gratingRotation = createProperty(name: "gratingRotation",
                                             info: gratingRotationInfo,
                                             measure: .angle,
                                             value: 0)

        return [period, color1, color2, phase, gratingRotation]
    }





    //checkerboard
    var checkerboardName: String {
        return """
        Checkerboard defined by two different colors and the size of the boxes.
        """
    }

    func createCheckerboard() -> [Property] {

        let boxSizeInfo = "Horizontal and vertical size of the boxes."
        let boxSize = createProperty(name: "boxSize",
                                     info: boxSizeInfo,
                                     measure: .size2d,
                                     value: 30)

        let color1Info = "First color."
        let color1 = createProperty(name: "color1",
                                    info: color1Info,
                                    measure: .color,
                                    value: 0)

        let color2Info = "Second color."
        let color2 = createProperty(name: "color2",
                                    info: color2Info,
                                    measure: .color,
                                    value: 1)

        let checkerboardPositionInfo = """
        Position of the center of the checkerboard relative to the center of the shape that contains it.
        """
        let checkerboardPosition = createProperty(name: "checkerboardPosition",
                                                  info: checkerboardPositionInfo,
                                                  measure: .position2d,
                                                  value: 0)

        let checkerboardRotationInfo = """
        Orientation of the checkerboard. This property only rotates the checkerboard but not the shape that masks it.
        """
        let checkerboardRotation = createProperty(name: "checkerboardRotation",
                                                  info: checkerboardRotationInfo,
                                                  measure: .angle,
                                                  value: 0)

        return [boxSize, color1, color2, checkerboardPosition, checkerboardRotation]
    }





    //radial checkerboard
    var radialCheckerboardName: String {
        return """
        Checkerboard with radial symmetry defined by two different colors and the angle size of the boxes.
        Divided into different circles (maximum 10 divisions).
        """
    }
    
    func createRadialCheckerboard() -> [Property] {

        let boxAngleSizeInfo = "Angle size of the boxes."
        let boxAngleSize = createProperty(name: "boxAngleSize",
                                          info: boxAngleSizeInfo,
                                          measure: .angle,
                                          value: 0.5236)

        let color1Info = "First color."
        let color1 = createProperty(name: "color1",
                                    info: color1Info,
                                    measure: .color,
                                    value: 0)

        let color2Info = "Second color."
        let color2 = createProperty(name: "color2",
                                    info: color2Info,
                                    measure: .color,
                                    value: 1)

        let checkerboardRotationInfo = """
        Orientation of the checkerboard. This property only rotates the checkerboard but not the shape that masks it.
        """
        let checkerboardRotation = createProperty(name: "checkerboardRotation",
                                                  info: checkerboardRotationInfo,
                                                  measure: .angle,
                                                  value: 0)

        let diameter1Info = "Diameter of the first circle"
        let diameter1 = createProperty(name: "diameter1",
                                       info: diameter1Info,
                                       measure: .size,
                                       value: 0)

        let diameter2Info = "Diameter of the second circle"
        let diameter2 = createProperty(name: "diameter2",
                                       info: diameter2Info,
                                       measure: .size,
                                       value: 0)

        let diameter3Info = "Diameter of the third circle"
        let diameter3 = createProperty(name: "diameter3",
                                       info: diameter3Info,
                                       measure: .size,
                                       value: 0)

        let diameter4Info = "Diameter of the fourth circle"
        let diameter4 = createProperty(name: "diameter4",
                                       info: diameter4Info,
                                       measure: .size,
                                       value: 0)

        let diameter5Info = "Diameter of the fifth circle"
        let diameter5 = createProperty(name: "diameter5",
                                       info: diameter5Info,
                                       measure: .size,
                                       value: 0)

        let diameter6Info = "Diameter of the sixth circle"
        let diameter6 = createProperty(name: "diameter6",
                                       info: diameter6Info,
                                       measure: .size,
                                       value: 0)

        let diameter7Info = "Diameter of the seventh circle"
        let diameter7 = createProperty(name: "diameter7",
                                       info: diameter7Info,
                                       measure: .size,
                                       value: 0)

        let diameter8Info = "Diameter of the eighth circle"
        let diameter8 = createProperty(name: "diameter8",
                                       info: diameter8Info,
                                       measure: .size,
                                       value: 0)

        let diameter9Info = "Diameter of the ninth circle"
        let diameter9 = createProperty(name: "diameter9",
                                       info: diameter9Info,
                                       measure: .size,
                                       value: 0)

        let diameter10Info = "Diameter of the tenth circle"
        let diameter10 = createProperty(name: "diameter10",
                                        info: diameter10Info,
                                        measure: .size,
                                        value: 0)

        return [boxAngleSize, color1, color2, checkerboardRotation, diameter1, diameter2, diameter3, diameter4,
                diameter5, diameter6, diameter7, diameter8, diameter9, diameter10]
    }
}
