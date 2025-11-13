//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import AVFoundation
import UIKit

class Settings {

    let device: Device

    let screenInfo: String
    var maximumFrameRate: Int
    var width: Float
    var height: Float
    var audioRate: Int
    var radiansPerDegree: Float

    var distance: Float
    var brightness: Double
    var maximumBrightness: Float
    var maximumBrightnessApple: Float
    var ppi: Float
    var ppiCanChange: Bool
    var resolutionCanChange: Bool
    var ppcm: Float
    var ppVisualAngleDegree: Float
    var cmPerPixel: Float
    var inchPerPixel: Float

    var rampTime: Float
    var frameRate: Int
    var delta: Float
    var delayAudio60: Float
    var delayAudio120: Float
    var positionX: Float
    var positionY: Float

    let userProperties: [Property]
    var deviceProperties: [Property]

    let versionProperty: Property
    let descriptionProperty: Property
    let systemProperty: Property
    var userProperty: Property
    var emailProperty: Property
    var rampTimeProperty: Property
    var ppiProperty: Property
    var maximumFrameRateProperty: Property
    var maximumBrightnessProperty: Property
    var audioRateProperty: Property
    var resolutionProperty: Property
    var positionXProperty: Property
    var positionYProperty: Property

    var delayAudio60Property: Property
    var delayAudio120Property: Property
    
    var retina: Float

    init(device: Device) {
        self.device = device

        self.screenInfo = device.screenInfo
        self.maximumFrameRate = device.maximumFrameRate
        
        var shouldUseMacConfiguration = false
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                shouldUseMacConfiguration = true
            }
        }
        
        if shouldUseMacConfiguration {
            let tempEngine = AVAudioEngine()
            self.audioRate = Int(tempEngine.outputNode.outputFormat(forBus: 0).sampleRate)
        } else {
            self.audioRate = Int(AVAudioSession.sharedInstance().sampleRate)
        }
        
        self.radiansPerDegree = Constants.radiansPerDegree

        self.distance = Constants.defaultDistanceCm
        self.brightness = Constants.defaultBrightness
        
        self.retina = Float(UIScreen.main.scale)

        if let maximumBrightnessApple = device.brightness {
            self.maximumBrightnessApple = maximumBrightnessApple
        } else {
            self.maximumBrightnessApple = Constants.epsilon
        }

        if let ppi = device.ppi {
            self.ppi = ppi
            self.ppiCanChange = false
        } else {
            let ppi = max(UserDefaults.standard.float(forKey: "ppi"), Constants.epsilon)
            self.ppi = ppi
            self.ppiCanChange = true
        }

        if let width = device.width {
            self.width = width
            self.resolutionCanChange = false
        } else {
            let width = max(UserDefaults.standard.float(forKey: "testWindowSize"), Constants.minimumResolutionMac)
            self.width = width
            self.resolutionCanChange = true
        }

        if let height = device.height {
            self.height = height
        } else {
            let height = max(UserDefaults.standard.float(forKey: "testWindowSize1"), Constants.minimumResolutionMac)
            self.height = height
        }

        self.frameRate = self.maximumFrameRate

        self.ppcm = self.ppi / Constants.cmsInInch
        self.ppVisualAngleDegree = self.ppcm * self.distance / Constants.distanceDegreeEqualCm

        self.cmPerPixel = 1 / max(Float(ppcm), Constants.epsilon)
        self.inchPerPixel = 1 / max(Float(ppi), Constants.epsilon)

        self.rampTime = UserDefaults.standard.bool(forKey: "rampTimeSaved") ?
            UserDefaults.standard.float(forKey: "rampTime") : Constants.rampTime

        self.delayAudio60 = UserDefaults.standard.bool(forKey: "delayAudio60Saved") ?
            UserDefaults.standard.float(forKey: "delayAudio60") : 0

        self.delayAudio120 = UserDefaults.standard.bool(forKey: "delayAudio120Saved") ?
            UserDefaults.standard.float(forKey: "delayAudio120") : 0

        self.maximumBrightness = UserDefaults.standard.bool(forKey: "maximumBrightnessSaved") ?
            UserDefaults.standard.float(forKey: "maximumBrightness") : self.maximumBrightnessApple

        self.positionX = UserDefaults.standard.bool(forKey: "testWindowPositionXSaved") ?
            UserDefaults.standard.float(forKey: "testWindowPositionX") : 0

        self.positionY = UserDefaults.standard.bool(forKey: "testWindowPositionYSaved") ?
            UserDefaults.standard.float(forKey: "testWindowPositionY") : 0

        self.delta = 1 / Float(self.frameRate)

        let systemString = "\(device.systemName), version: \(device.systemVersion)"
        let userString = UserDefaults.standard.string(forKey: "user") ?? "user"
        let emailString = UserDefaults.standard.string(forKey: "email") ?? "user@email.com"

        self.userProperty = SettingsData.makeUserProperty(text: userString)
        self.emailProperty = SettingsData.makeEmailProperty(text: emailString)

        self.versionProperty = SettingsData.makeVersionProperty()
        self.descriptionProperty = SettingsData.makeDescriptionProperty(text: device.description)
        self.systemProperty = SettingsData.makeSystemProperty(text: systemString)
        self.maximumFrameRateProperty = SettingsData.makeFrameRateProperty(float: Float(self.maximumFrameRate))
        self.maximumBrightnessProperty = SettingsData.makeBrightnessProperty(float: self.maximumBrightness)
        self.audioRateProperty = SettingsData.makeAudioRateProperty(float: Float(self.audioRate))
        self.resolutionProperty = SettingsData.makeResolutionProperty(float: self.width,
                                                                      float1: self.height,
                                                                      onlyInfo: !resolutionCanChange)
        self.ppiProperty = SettingsData.makePpiProperty(float: self.ppi, onlyInfo: !ppiCanChange)

        self.rampTimeProperty = SettingsData.makeRampTimeProperty(float: self.rampTime)
        self.delayAudio60Property = SettingsData.makeDelayAudio60Property(float: self.delayAudio60)
        self.delayAudio120Property = SettingsData.makeDelayAudio120Property(float: self.delayAudio120)

        self.positionXProperty = SettingsData.makePositionXProperty(float: positionX)
        self.positionYProperty = SettingsData.makePositionYProperty(float: positionY)
        
        self.userProperties = [userProperty, emailProperty]

        self.deviceProperties = [versionProperty, descriptionProperty, systemProperty, audioRateProperty,
                                 maximumFrameRateProperty, resolutionProperty, ppiProperty, maximumBrightnessProperty,
                                 rampTimeProperty, delayAudio60Property]

        if self.maximumFrameRate == 120 {
            self.deviceProperties.append(delayAudio120Property)
        }
    }

    func update(from test: Test) {
        distance = test.distance.properties[0].float
        brightness = Double(test.brightness.float)
        frameRate = test.frameRate.selectedValue == 0 ? 60 : 120
        delta = 1 / Float(frameRate)
        ppVisualAngleDegree = ppcm * distance / Constants.distanceDegreeEqualCm
    }

    func updateAudioRate(new: Double) {
        self.audioRateProperty = SettingsData.makeAudioRateProperty(float: Float(new))
        self.audioRate = Int(new)
    }

    func updateProperties() {
        if let ppi = device.ppi {
            self.ppi = ppi
            self.ppiCanChange = false
        } else {
            let ppi = max(UserDefaults.standard.float(forKey: "ppi"), Constants.epsilon)
            self.ppi = ppi
            self.ppiCanChange = true
        }

        if let width = device.width {
            self.width = width
            self.resolutionCanChange = false
        } else {
            let width = max(UserDefaults.standard.float(forKey: "testWindowSize"), Constants.minimumResolutionMac)
            self.width = width
            self.resolutionCanChange = true
        }

        if let height = device.height {
            self.height = height
        } else {
            let height = max(UserDefaults.standard.float(forKey: "testWindowSize1"), Constants.minimumResolutionMac)
            self.height = height
        }

        self.ppcm = self.ppi / Constants.cmsInInch
        self.ppVisualAngleDegree = self.ppcm * self.distance / Constants.distanceDegreeEqualCm

        self.cmPerPixel = 1 / max(Float(ppcm), Constants.epsilon)
        self.inchPerPixel = 1 / max(Float(ppi), Constants.epsilon)

        self.rampTime = UserDefaults.standard.bool(forKey: "rampTimeSaved") ?
            UserDefaults.standard.float(forKey: "rampTime") : Constants.rampTime

        self.delayAudio60 = UserDefaults.standard.bool(forKey: "delayAudio60Saved") ?
            UserDefaults.standard.float(forKey: "delayAudio60") : 0

        self.delayAudio120 = UserDefaults.standard.bool(forKey: "delayAudio120Saved") ?
            UserDefaults.standard.float(forKey: "delayAudio120") : 0

        self.maximumBrightness = UserDefaults.standard.bool(forKey: "maximumBrightnessSaved") ?
            UserDefaults.standard.float(forKey: "maximumBrightness") : self.maximumBrightnessApple

        self.positionX = UserDefaults.standard.bool(forKey: "testWindowPositionXSaved") ?
            UserDefaults.standard.float(forKey: "testWindowPositionX") : 0

        self.positionY = UserDefaults.standard.bool(forKey: "testWindowPositionYSaved") ?
            UserDefaults.standard.float(forKey: "testWindowPositionY") : 0
    }

    var info: String {

        return """
        DEVICE: \(descriptionProperty.string)
        SYSTEM: \(systemProperty.string)
        VERSION: \(versionProperty.string)
        AUDIO RATE: \(audioRateProperty.string)
        SCREEN RESOLUTION: \(resolutionProperty.string)
        PPI: \(ppiProperty.string)
        RAMPTIME: \(rampTimeProperty.string)
        MAXIMUM LUMINANCE: \(maximumBrightnessProperty.string)
        """
    }
}

