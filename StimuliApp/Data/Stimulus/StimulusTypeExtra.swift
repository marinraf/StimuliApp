//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

extension StimuliType {

    var name: String {
        return self.rawValue
    }
    
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

    var metal: Bool {
        return style == .metalRegular || style == .dots || style == .image
    }

    func createProperty(name: String, info: String, measure: Measure, value: Float) -> Property {
        return StimulusData.createProperty(name: name, info: info, measure: measure, value: value)
    }


    func createDotsProperties() -> [Property] {

        let density = Property(name: "density",
                               info: "The density of dots per pixel.",
                               propertyType: .finalFloat,
                               unitType: .valueFrom0to1,
                               float: 0.001)


        let coherence = createProperty(name: "coherence",
                                       info: "The proportion of type1 dots from the total number of dots.",
                                       measure: .valueFrom0to1,
                                       value: 0.5)

        let dotsLife1 = createProperty(name: "dotsLife1",
                                       info: """
                                       The life of each one of the dots. When a dot reaches their life it \
                                       disappears and another dot is created in a random position. If life is zero \
                                       the dots change their position each frame.
                                       """,
                                       measure: .time,
                                       value: 0.05)

        let diameter1 = createProperty(name: "diameter1",
                                       info: "The diameter of type1 dots.",
                                       measure: .size,
                                       value: 8)

        let direction1 = Property(name: "direction1",
                                  info: "Possibles ways to establish the dot direction for type1 dots.",
                                  propertyType: .direction,
                                  unitType: .decimal,
                                  fixedValues: FixedDirection.allCases.map({ $0.name }),
                                  selectedValue: 1)

        let color1 = createProperty(name: "color1",
                                    info: "The color of type1 dots.",
                                    measure: .color,
                                    value: 0)

        let dotsLife2 = createProperty(name: "dotsLife2",
                                       info: """
                                       The life of each one of the dots. When a dot reaches their life it \
                                       disappears and another dot is created in a random position. If life is zero \
                                       the dots change their position each frame.
                                       """,
                                       measure: .time,
                                       value: 0)

        let diameter2 = createProperty(name: "diameter2",
                                       info: "The diameter of type2 dots.",
                                       measure: .size,
                                       value: 8)

        let direction2 = Property(name: "direction2",
                                  info: "Possibles ways to establish the dot direction for type2 dots.",
                                  propertyType: .direction,
                                  unitType: .decimal,
                                  fixedValues: FixedDirection.allCases.map({ $0.name }),
                                  selectedValue: 0)

        let color2 = createProperty(name: "color2",
                                    info: "The color of type2 dots.",
                                    measure: .color,
                                    value: 0)

        return [density, coherence, dotsLife1, diameter1, direction1, color1, dotsLife2, diameter2, direction2, color2]
    }

    func createTextProperties() -> [Property] {

        let text = Property(name: "textNumber",
                            info: "The number of the text selected from the list of texts.",
                            propertyType: .text,
                            unitType: .positiveIntegerWithoutZero,
                            float: 1)

        let font = Property(name: "font",
                            info: "The font of the text.",
                            propertyType: .font,
                            unitType: .decimal,
                            float: 0)

        font.text = "HelveticaNeue"

        let textSize = Property(name: "textSize",
                                info: "The size of the text in points.",
                                propertyType: .finalFloat,
                                unitType: .positiveIntegerWithoutZero,
                                float: 30)

        let positionX = Property(name: "positionX",
                                 info: "The x position relative to the center of the screen.",
                                 propertyType: .simpleFloatText,
                                 unitType: .size,
                                 float: 0)

        let positionY = Property(name: "positionY",
                                 info: "The y position relative to the center of the screen.",
                                 propertyType: .simpleFloatText,
                                 unitType: .size,
                                 float: 0)

        let color = createProperty(name: "textColor", //don´t change the name because is checked in addPropertiesToColor
                                   info: "Color of the text.",
                                   measure: .color,
                                   value: 0)

        return [text, font, textSize, positionX, positionY, color]
    }

    func createImageProperties() -> [Property] {

        let image = Property(name: "imageNumber",
                             info: "The number of the image selected from the lists of images.",
                             propertyType: .image,
                             unitType: .positiveIntegerWithoutZero,
                             float: 1)

        let imageCenter = createProperty(name: "imageCenter",
                                         info: """
                                               Position of the center of the image relative to the center of the \
                                               shape that contains it.
                                               """,
                                         measure: .position2d,
                                         value: 0)

        let imageRotation = createProperty(name: "imageRotation",
                                           info: """
                                                 Orientation of the image.
                                                 This property only rotates the image but not the shape that masks it.
                                                 """,
                                           measure: .angle,
                                           value: 0)

        return [image, imageCenter, imageRotation]
    }

    func createVideoProperties() -> [Property] {

        let video = Property(name: "videoNumber",
                             info: "The number of the video selected from the lists of videos.",
                             propertyType: .video,
                             unitType: .positiveIntegerWithoutZero,
                             float: 1)

        return [video]
    }

    func createAudioProperties() -> [Property] {

        let audio = Property(name: "audioNumber",
                             info: "The number of the audio selected from the lists of audios.",
                             propertyType: .audio,
                             unitType: .positiveIntegerWithoutZero,
                             float: 1)

        let amplitude = Property(name: "amplitude",
                                 info: """
                                 The amplitude of the sound.
                                 The perceived loudness of the sound is approximately proportional to the logarithm \
                                 of the amplitude.
                                 """,
                                 propertyType: .finalFloat,
                                 unitType: .valueFrom0to1,
                                 float: 0.5)

        return [audio, amplitude]
    }

    func createPureToneProperties() -> [Property] {

        let soundType = Property(name: "soundType",
                                  info: "Sound type.",
                                  propertyType: .soundType,
                                  unitType: .decimal,
                                  fixedValues: FixedSoundType.allCases.map({ $0.name }),
                                  selectedValue: 0)

        let amplitude = Property(name: "amplitude",
                                 info: """
                                 The amplitude of the sinewave.
                                 The perceived loudness of the sound is approximately proportional to the logarithm \
                                 of the amplitude.
                                 """,
                                 propertyType: .finalFloat,
                                 unitType: .valueFrom0to1,
                                 float: 0.5)

        let leftRightBalance =  Property(name: "leftRightBalance",
                                info: """
                                From 0 = totally to the left to 1 = totally to the right.
                                leftAmplitude = leftRightBalance * amplitude
                                rightAmplitude = (1 - leftRightBalance) * amplitude
                                """,
                                propertyType: .finalFloat,
                                unitType: .valueFrom0to1,
                                float: 0.5)

        return [soundType, amplitude, leftRightBalance]
    }

}

extension TimeFunctions {

    var name: String {
        return self.rawValue
    }

    func createProperty(for property: Property,
                        name: String,
                        info: String,
                        measureSame: Int,
                        measureTime: Int,
                        defaultValue: Float) -> Property {

        return StimulusData.createProperty(for: property,
                                           name: name,
                                           info: info,
                                           measureSame: measureSame,
                                           measureTime: measureTime,
                                           defaultValue: defaultValue)
    }
}
