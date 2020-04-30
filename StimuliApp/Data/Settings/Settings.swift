//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import AVFoundation

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

    let userProperties: [Property]
    let deviceProperties: [Property]

    let descriptionProperty: Property
    let systemProperty: Property
    var userProperty: Property
    var emailProperty: Property
    var rampTimeProperty: Property
    var ppiProperty: Property
    var maximumFrameRateProperty: Property
    var audioRateProperty: Property
    var resolutionProperty: Property

    init(device: Device) {
        self.device = device

        self.screenInfo = device.screenInfo
        self.maximumFrameRate = device.maximumFrameRate
        self.audioRate = Int(AVAudioSession.sharedInstance().sampleRate)
        self.radiansPerDegree = Constants.radiansPerDegree

        self.distance = Constants.defaultDistanceCm
        self.brightness = Constants.defaultBrightness

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

        self.delta = 1 / Float(self.frameRate)

        let systemString = "\(device.systemName), version: \(device.systemVersion)"
        let userString = UserDefaults.standard.string(forKey: "user") ?? "user"
        let emailString = UserDefaults.standard.string(forKey: "email") ?? "user@email.com"

        self.userProperty = SettingsData.makeUserProperty(text: userString)
        self.emailProperty = SettingsData.makeEmailProperty(text: emailString)

        self.descriptionProperty = SettingsData.makeDescriptionProperty(text: device.description)
        self.systemProperty = SettingsData.makeSystemProperty(text: systemString)
        self.maximumFrameRateProperty = SettingsData.makeFrameRateProperty(float: Float(self.maximumFrameRate))
        self.audioRateProperty = SettingsData.makeAudioRateProperty(float: Float(self.audioRate))
        self.resolutionProperty = SettingsData.makeResolutionProperty(float: self.width,
                                                                      float1: self.height,
                                                                      onlyInfo: !resolutionCanChange)
        self.ppiProperty = SettingsData.makePpiProperty(float: self.ppi, onlyInfo: !ppiCanChange)

        self.rampTimeProperty = SettingsData.makeRampTimeProperty(float: self.rampTime)

        self.userProperties = [userProperty, emailProperty]
        self.deviceProperties = [descriptionProperty, systemProperty, maximumFrameRateProperty, audioRateProperty,
                                 resolutionProperty, ppiProperty, rampTimeProperty]
        }

    func update(from test: Test) {
        distance = test.distance.properties[0].float
        brightness = Double(test.brightness.float)
        frameRate = test.frameRate.selectedValue == 0 ? 60 : 120
        delta = 1 / Float(frameRate)
        ppVisualAngleDegree = ppcm * distance / Constants.distanceDegreeEqualCm
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
            let width = max(UserDefaults.standard.float(forKey: "screenResolution"), Constants.minimumResolutionMac)
            self.width = width
            self.resolutionCanChange = true
        }

        if let height = device.height {
            self.height = height
        } else {
            let height = max(UserDefaults.standard.float(forKey: "screenResolution1"), Constants.minimumResolutionMac)
            self.height = height
        }

        self.ppcm = self.ppi / Constants.cmsInInch
        self.ppVisualAngleDegree = self.ppcm * self.distance / Constants.distanceDegreeEqualCm

        self.cmPerPixel = 1 / max(Float(ppcm), Constants.epsilon)
        self.inchPerPixel = 1 / max(Float(ppi), Constants.epsilon)

        self.rampTime = UserDefaults.standard.bool(forKey: "rampTimeSaved") ?
            UserDefaults.standard.float(forKey: "rampTime") : Constants.rampTime
    }

    var info: String {

        return """
        DEVICE: \(descriptionProperty.string)
        SYSTEM: \(systemProperty.string)
        AUDIO RATE: \(audioRateProperty.string)
        SCREEN RESOLUTION: \(resolutionProperty.string)
        PPI: \(ppiProperty.string)
        RAMPTIME: \(rampTimeProperty.string)
        """
    }
}
