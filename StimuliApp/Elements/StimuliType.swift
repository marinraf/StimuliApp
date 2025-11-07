//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation



enum StimuliType: String, Codable, CaseIterable {
    
    case patch
    case gradient
    case grating
    case circularGrating
    case checkerboard
    case radialCheckerboard
    case dots
    case image
    case text
    case video
    case audio
    case pureTone
    
    
    
    
    var description: String {
        switch self {
        case .patch:
            return """
            Patch with a uniform color.
            """
        case .gradient:
            return """
            Patch with a color gradient. Transitions linearly from color1 to color2 over the gradient size.
            """
        case .grating:
            return """
            Grating whose color oscillates sinusoidally between color1 and color2.
            """
        case .circularGrating:
            return """
            Circular grating whose color oscillates sinusoidally between color1 and color2.
            """
        case .checkerboard:
            return """
            Checkerboard defined by two colors and the size of the boxes.
            """
        case .radialCheckerboard:
            return """
            Radial checkerboard defined by two colors and the angular size of the boxes.
            Divided into concentric rings (up to 10 divisions).
            """
        case .dots:
            return """
            Random dots.
            """
        case .image:
            return """
            Image.
            """
        case .text:
            return """
            Text.
            """
        case .video:
            return """
            Play video from a source.
            """
        case .audio:
            return """
            Play audio from a source.
            """
        case .pureTone:
            return """
            Play auto-generated white noise or a pure tone.
            """
        }
    }

    var typeProperties: [Property] {
        switch self {
        case .patch:
            return createPatchProperties()
        case .gradient:
            return createGradientProperties()
        case .grating:
            return createGratingProperties()
        case .circularGrating:
            return createCircularGratingProperties()
        case .checkerboard:
            return createCheckerboardProperties()
        case .radialCheckerboard:
            return createRadialCheckerboardProperties()
        case .dots:
            return createDotsProperties()
        case .image:
            return createImageProperties()
        case .text:
            return createTextProperties()
        case .video:
            return createVideoProperties()
        case .audio:
            return createAudioProperties()
        case .pureTone:
            return createPureToneProperties()
        }
    }
    
    
    
    
    //patch
    func createPatchProperties() -> [Property] {
        let colorInfo = "Patch color."
        let color = createProperty(name: "color",
                                   info: colorInfo,
                                   measure: .color,
                                   value: 0)
        return [color]
    }
    
    
    
    
    
    //gradient
    func createGradientProperties() -> [Property] {
        let gradientSizeInfo = """
        Gradient size.
        Defined as the distance from the position where color = color1 to the position where color = color2.
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
        Position of the gradient’s center relative to the center of the containing shape.
        Measured along the gradient direction set by gradientRotation.
        """
        let gradientPosition = createProperty(name: "gradientPosition",
                                              info: gradientPositionInfo,
                                              measure: .size,
                                              value: 0)
        let gradientRotationInfo = """
        Gradient orientation. This property rotates only the gradient, not the masking shape.
        """
        let gradientRotation = createProperty(name: "gradientRotation",
                                              info: gradientRotationInfo,
                                              measure: .angle,
                                              value: 0)
        return [gradientSize, color1, color2, gradientPosition, gradientRotation]
    }
    
    
    
    
    
    //grating
    func createGratingProperties() -> [Property] {
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
        Grating orientation. This property rotates only the grating, not the masking shape.
        """
        let gratingRotation = createProperty(name: "gratingRotation",
                                             info: gratingRotationInfo,
                                             measure: .angle,
                                             value: 0)
        return [period, color1, color2, phase, gratingRotation]
    }
    
    
    
    
    
    //checkerboard
    func createCheckerboardProperties() -> [Property] {
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
        Position of the checkerboard’s center relative to the center of the containing shape.
        """
        let checkerboardPosition = createProperty(name: "checkerboardPosition",
                                                  info: checkerboardPositionInfo,
                                                  measure: .position2d,
                                                  value: 0)
        let checkerboardRotationInfo = """
        Checkerboard orientation. This property rotates only the checkerboard, not the masking shape.
        """
        let checkerboardRotation = createProperty(name: "checkerboardRotation",
                                                  info: checkerboardRotationInfo,
                                                  measure: .angle,
                                                  value: 0)
        return [boxSize, color1, color2, checkerboardPosition, checkerboardRotation]
    }
    
    
    
    
    
    //radial checkerboard
    func createRadialCheckerboardProperties() -> [Property] {
        let boxAngleSizeInfo = "Angular size of the boxes."
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
        Checkerboard orientation. This property rotates only the checkerboard, not the masking shape.
        """
        let checkerboardRotation = createProperty(name: "checkerboardRotation",
                                                  info: checkerboardRotationInfo,
                                                  measure: .angle,
                                                  value: 0)
        let diameter1Info = "Diameter of the first ring"
        let diameter1 = createProperty(name: "diameter1",
                                       info: diameter1Info,
                                       measure: .size,
                                       value: 0)
        let diameter2Info = "Diameter of the second ring"
        let diameter2 = createProperty(name: "diameter2",
                                       info: diameter2Info,
                                       measure: .size,
                                       value: 0)
        let diameter3Info = "Diameter of the third ring"
        let diameter3 = createProperty(name: "diameter3",
                                       info: diameter3Info,
                                       measure: .size,
                                       value: 0)
        let diameter4Info = "Diameter of the fourth ring"
        let diameter4 = createProperty(name: "diameter4",
                                       info: diameter4Info,
                                       measure: .size,
                                       value: 0)
        let diameter5Info = "Diameter of the fifth ring"
        let diameter5 = createProperty(name: "diameter5",
                                       info: diameter5Info,
                                       measure: .size,
                                       value: 0)
        let diameter6Info = "Diameter of the sixth ring"
        let diameter6 = createProperty(name: "diameter6",
                                       info: diameter6Info,
                                       measure: .size,
                                       value: 0)
        let diameter7Info = "Diameter of the seventh ring"
        let diameter7 = createProperty(name: "diameter7",
                                       info: diameter7Info,
                                       measure: .size,
                                       value: 0)
        let diameter8Info = "Diameter of the eighth ring"
        let diameter8 = createProperty(name: "diameter8",
                                       info: diameter8Info,
                                       measure: .size,
                                       value: 0)
        let diameter9Info = "Diameter of the ninth ring"
        let diameter9 = createProperty(name: "diameter9",
                                       info: diameter9Info,
                                       measure: .size,
                                       value: 0)
        let diameter10Info = "Diameter of the tenth ring"
        let diameter10 = createProperty(name: "diameter10",
                                        info: diameter10Info,
                                        measure: .size,
                                        value: 0)
        return [boxAngleSize, color1, color2, checkerboardRotation, diameter1, diameter2, diameter3, diameter4,
                diameter5, diameter6, diameter7, diameter8, diameter9, diameter10]
    }
    
    
    //circular grating
    func createCircularGratingProperties() -> [Property] {
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
        return [period, color1, color2, phase]
    }
}


