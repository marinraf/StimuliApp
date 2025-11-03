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
    var longFrames: [Frame]
    var numberOfFrames: Int
    var numberOfErrors: Int

    var drawTime: Double
    var texturesAndDotsTime: Double
    var previousPresentedTime: Double
    
    var delay: Double
    
    init(frameRate: Int, delayAudio: Double) {
        self.frameRate = frameRate
        self.delta = 1 / Double(frameRate)
        self.longDuration = 1.25 * delta
        self.longFrames = []
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

    
    func updatePresentedTime(register: Bool,
                             scene: SceneTask,
                             previousScene: SceneTask,
                             initScene: Bool,
                             presentedTime: Double,
                             previousFrameSceneName: String,
                             previousFrameTrial: Int,
                             previousFrameTimeInFrames: Int) {
        
        if initScene {
            scene.realStartTime.append(presentedTime)
            previousScene.realEndTime.append(presentedTime)
            
            if Task.shared.scaleTime == 0 && scene.name != "sceneZero0o" {
                
                let interval = NSDate.init().timeIntervalSince1970
                let now = CACurrentMediaTime()
                Task.shared.scaleTime = now - interval
            }
        }

        let duration = presentedTime - previousPresentedTime

        if Task.shared.sceneTask.name != "sceneZero0o" && register {

            numberOfFrames += 1
                        
            if duration > 1.25 * delta {

                let frame = Frame(scene: previousFrameSceneName,
                                  trial: previousFrameTrial,
                                  frameScene: previousFrameTimeInFrames,
                                  duration: duration)

                longFrames.append(frame)
            }

        }
        previousPresentedTime = presentedTime
    }
    
}

