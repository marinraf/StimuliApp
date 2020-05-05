//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

struct DataTask {

    static var imageTextures: [MTLTexture] = []
    static var objectTextures: [MTLTexture] = []
    static var objectSizeMax: [(x: Int, y: Int)] = Array(repeating: (0, 0), count: Constants.maxNumberOfMetalStimuli)
    static var backgroundValues: [Float] = [] //variables
    static var metalValues: [[Float]] = [] //object * variables
    static var activatedBools: [Bool] = [] //object
    static var texturePositions: [Float] = Array(repeating: 0, count: 2 * Constants.maxNumberOfMetalStimuli)
    static var selectedObjects: [Float] = [] //layer0pos0 + layer1pos0 + layer2pos0 + layer0pos1...
    static var images: [Int] = []
}

struct TextObject {
    var activated: Bool
    var start: Int
    var end: Int
    var tag: Int
    var text: String
    var font: UIFont
    var positionX: CGFloat
    var positionY: CGFloat
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
}

struct VideoObject {
    var activated: Bool
    var start: Int
    var end: Int
    var tag: Int
    var url: URL?
}

struct AudioObject {
    var activated: Bool
    var dependCorrection: Bool
    var start: Int
    var end: Int
    var startFloat: Float
    var endFloat: Float
    var amplitude: Float
    var frequency: Float
    var channel: Float
    var url: URL?
}
