//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct SettingsData {

    static func makeUserProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.name,
                        text: text)
    }

    static func makeEmailProperty(text: String) -> Property {

        return Property(name: "email",
                        info: Texts.email,
                        text: text)
    }

    static func makeVersionProperty() -> Property {

        let property = Property(name: "version",
                                info: Texts.versionInfo,
                                text: Texts.version)

        property.onlyInfo = true
        return property
    }

    static func makeDescriptionProperty(text: String) -> Property {

        let property = Property(name: "description",
                                info: Texts.description,
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeSystemProperty(text: String) -> Property {

        let property = Property(name: "system",
                                info: Texts.system,
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeRampTimeProperty(float: Float) -> Property {

        return Property(name: "rampTime",
                        info: Texts.rampTime,
                        propertyType: .simpleFloat,
                        unitType: .rampTime,
                        float: float)
    }

    static func makePpiProperty(float: Float, onlyInfo: Bool) -> Property {

        let property = Property(name: "ppi",
                                info: Texts.ppi,
                                propertyType: .simpleFloat,
                                unitType: .pixelDensity,
                                float: float)

        property.onlyInfo = onlyInfo
        return property
    }

    static func makeFrameRateProperty(float: Float) -> Property {

        let property = Property(name: "maximumFrameRate",
                                info: Texts.maximumFrameRate,
                                propertyType: .simpleFloat,
                                unitType: .frequency,
                                float: float)

        property.onlyInfo = true
        return property
    }

    static func makeBrightnessProperty(float: Float) -> Property {

        let property = Property(name: "maximumLuminance",
                                info: Texts.maximumBrightness,
                                propertyType: .simpleFloat,
                                unitType: .maxBrightness,
                                float: float)

        property.onlyInfo = false
        return property
    }

    static func makeAudioRateProperty(float: Float) -> Property {

        let property = Property(name: "audioRate",
                                info: Texts.audioRate,
                                propertyType: .simpleFloat,
                                unitType: .frequency,
                                float: float)

        property.onlyInfo = true
        return property
    }

    static func makeDelayAudio60Property(float: Float) -> Property {

        return Property(name: "delayAudio60",
                        info: Texts.delayAudio60,
                        propertyType: .simpleFloat,
                        unitType: .delayTime,
                        float: float)
    }

    static func makeDelayAudio120Property(float: Float) -> Property {

        return Property(name: "delayAudio120",
                        info: Texts.delayAudio120,
                        propertyType: .simpleFloat,
                        unitType: .delayTime,
                        float: float)
    }

    static func makePositionXProperty(float: Float) -> Property {

        return Property(name: "testWindowPositionX",
                        info: Texts.testWindowPositionX,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerOrZero,
                        float: float)
    }

    static func makePositionYProperty(float: Float) -> Property {

        return Property(name: "testWindowPositionY",
                        info: Texts.testWindowPositionY,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerOrZero,
                        float: float)
    }

    static func makeResolutionProperty(float: Float, float1: Float, onlyInfo: Bool) -> Property {

        
        let property = Property(name: "screenResolution",
                                  info: Texts.resolution,
                                  propertyType: .dobleSize,
                                  unitType: .pixelSize,
                                  float: float)
        
        #if targetEnvironment(macCatalyst)
        property.name = "testWindowSize"
        #endif
        property.float1 = float1
        property.onlyInfo = onlyInfo
        return property
    }
}
