//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import AVFoundation


struct Frame {
    let scene: String
    let trial: Int
    let frameScene: Int
    let duration: Double

    var info: String {
        return """
        scene: \(scene)
        trial: \(trial)
        frame: \(frameScene)
        duration: \(duration)
        """
    }
}

class FrameControl {

    var frameRate: Int
    var delta: Double
    var longDuration: Double
    var initScene: Bool
    var initSceneTimeReal: Double
    var longFrames: [Frame]
    var measure: Bool
    var numberOfFrames: Int
    var numberOfErrors: Int

    var drawTime: Double
    var texturesAndDotsTime: Double
    var previousPresentedTime: Double
    
    var delay: Double
    
    var realInitTimes: [String: [Double]]
    var realEndTimes: [String: [Double]]

    init(frameRate: Int, delayAudio: Double) {
        self.frameRate = frameRate
        self.delta = 1 / Double(frameRate)
        self.longDuration = 1.25 * delta
        self.initScene = false
        self.initSceneTimeReal = 0
        self.longFrames = []
        self.measure = true
        self.numberOfFrames = 0
        self.numberOfErrors = 0

        self.drawTime = 0
        self.texturesAndDotsTime = 0
        self.previousPresentedTime = 0
        
        self.delay = 0

        if frameRate == 60 {
            self.delay = Constants.delayAudio60 + delayAudio
        } else {
            self.delay = Constants.delayAudio120 + delayAudio
        }
        
        self.realInitTimes = [:]
        self.realEndTimes = [:]
    }

    var totalFrames: Int {
        return max(numberOfFrames, 1)
    }

    var percentageLongFrames: String {
        let value: Double = Double(longFrames.count) / Double(totalFrames) * 100

        let percentage = String(format: "%.05f", value)

        return "\(percentage)%"
    }

    var longFramesString: String {
        let duration = String(format: "%.05f", delta)

        var longlist = ""

        for longFrame in longFrames {
            longlist += longFrame.info
            longlist += "\n"
        }

        return """
        Frame rate: \(frameRate) Hz.

        Expected duration of a frame: \(duration).

        The number of long frames is: \(longFrames.count)

        from a total number of: \(totalFrames) frames.

        The percentage of long frames is: \(percentageLongFrames).

        List of long frames:

        \(longlist)
        """
    }

    func updateDrawTime() {
        drawTime = CACurrentMediaTime()
    }

    func updateTextureTime(displayRender: DisplayRender?) {
        texturesAndDotsTime = CACurrentMediaTime()
        if numberOfFrames < 100 {
            if texturesAndDotsTime - drawTime > delta - 0.002 {  // it is not in sync
                numberOfErrors += 1
            }
            if numberOfErrors == 3 {
                numberOfErrors += 1
                displayRender?.needToSync = true
            }
        }
    }

    
    func updatePresentedTime(timeInFrames: Int,
                             register: Bool,
                             initSceneTime: Bool,
                             presentedTime: Double,
                             sceneId: String,
                             previousSceneId: String) {
        
        print(CACurrentMediaTime(), " me llega el update: ", presentedTime, " el time in frames es: ", timeInFrames)
        
        if initSceneTime {
            print(CACurrentMediaTime(), "* asigno a init scene el valor: ", presentedTime, " el time en frames es: ", timeInFrames)
            initSceneTimeReal = presentedTime

            realInitTimes[sceneId] = (realInitTimes[sceneId] ?? []) + [presentedTime]
            realEndTimes[previousSceneId] = (realEndTimes[previousSceneId] ?? []) + [presentedTime]
        }
        
        let duration = presentedTime - previousPresentedTime

        if Task.shared.sceneTask.name != "sceneZero0o" {

            numberOfFrames += 1
            
            if duration > 1.25 * delta && measure && register
                && Task.shared.sceneTask.frameControl {

                let frame = Frame(scene: Task.shared.sceneTask.name,
                                  trial: Task.shared.sectionTask.currentTrial + 1,
                                  frameScene: timeInFrames - 1,
                                  duration: duration)

                longFrames.append(frame)
            }

        }
        previousPresentedTime = presentedTime
    }
    
}

