//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import AVFoundation

// DEBUG MODE
// make debug = true in FrameControl class to get a print of the timings of all frames

struct Frame {
    let scene: String
    let trial: Int
    let frameScene: Int
    let frameTotal: Int
    let initTime: Double
    let endTime: Double
    let duration: Double
    let texturesAndDotsTime: Double
    let encodeTime: Double
    let commitTime: Double
    let responded: Bool
    let measure: Bool
    let long: Bool

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
    var type: Int
    var time: Double
    var initScene: Bool
    var initScene2: Bool
    var initSceneTime: Double
    var frames: [Frame]
    var longFrames: [Frame]
    var measure: Bool
    var allFrames: Int

    var previousDrawables: [MTLDrawable]
    var initSceneDrawable: MTLDrawable?

    var drawTime: Double

    var lastDrawableTime: Double
    var numberOfFrames: Int
    var diff: Double
    var delay: Double

    var texturesAndDotsTime: Double // for DEBUG MODE only
    var encodeTime: Double // for DEBUG MODE only
    var commitTime: Double // for DEBUG MODE only

    var constantDelay: Double

    var numberOfErrors: Int

    let debug: Bool

    init(frameRate: Int, maximumFrameRate: Double, delayAudio: Double) {
        self.frameRate = frameRate
        self.delta = 1 / Double(frameRate)
        self.longDuration = 1.25 * delta
        self.time = 0
        self.initScene = false
        self.initScene2 = false
        self.initSceneTime = 0
        self.frames = []
        self.longFrames = []
        self.measure = true
        self.allFrames = 0

        self.previousDrawables = []

        self.drawTime = 0

        self.lastDrawableTime = 0
        self.numberOfFrames = 0
        self.diff = 0
        self.delay = 0

        self.texturesAndDotsTime = 0
        self.encodeTime = 0
        self.commitTime = 0

        self.numberOfErrors = 0

        self.debug = false

        if maximumFrameRate == 120 {
            if frameRate == 60 {
                self.type = 1 // iPad Pro at 60
                self.constantDelay = Constants.delayAudio60 + delayAudio
            } else {
                self.type = 2 // iPad Pro at 120
                self.constantDelay = Constants.delayAudio120 + delayAudio
            }
        } else {
            self.type = 0 // iPad or iPhone or mac
            self.constantDelay = Constants.delayAudio60 + delayAudio
        }
    }

    var initSceneTimeReal: Double {
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
//            we should use presentedTime but it is not working always, apple bug
//            return initSceneDrawable?.presentedTime ?? 0
            return initSceneTime + Constants.delayResponse
        } else {
            return initSceneTime + Constants.delayResponse
        }
        #else
        return initSceneDrawable?.presentedTime ?? 0
        #endif
    }

    var totalFrames: Int {
        return max(allFrames, 1)
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

    func updateDrawTime(displayRender: DisplayRender?) {

        guard let displayRender = displayRender else { return }

        drawTime = CACurrentMediaTime()

        numberOfFrames = 0
        diff = 0

        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 13.4, *) {
            if previousDrawables.count == 5 {
                lastDrawableTime = previousDrawables[2].presentedTime
                if lastDrawableTime > 1 {
                    diff = drawTime - lastDrawableTime
                }
            }
        }
        #else
        if previousDrawables.count == 5 {
            lastDrawableTime = previousDrawables[2].presentedTime
            if lastDrawableTime > 1 {
                diff = drawTime - lastDrawableTime
            }
        }
        #endif

        delay = constantDelay - diff

        let responded = displayRender.responded

        if initScene {
            Task.shared.previousSceneTask.saveSceneTime(time: drawTime)
            initSceneTime = drawTime
            initScene = false
            initScene2 = true
        }

        let duration = drawTime - time
        var long = false

        if duration > 1.25 * delta && measure && !responded
            && Task.shared.sceneTask.frameControl {
            long = true
        }

        if Task.shared.sceneTask.name != "sceneZero0o" {

            allFrames += 1

            if debug || long {

                let frame = Frame(scene: Task.shared.sceneTask.name,
                                  trial: Task.shared.sectionTask.currentTrial + 1,
                                  frameScene: displayRender.timeInFrames,
                                  frameTotal: allFrames,
                                  initTime: time,
                                  endTime: drawTime,
                                  duration: duration,
                                  texturesAndDotsTime: texturesAndDotsTime,
                                  encodeTime: encodeTime,
                                  commitTime: commitTime,
                                  responded: responded,
                                  measure: measure,
                                  long: long)

                if debug {
                    frames.append(frame)
                }

                if long && allFrames > 0 {
                    longFrames.append(frame)
                }
            }

        }
        time = drawTime
    }

    func updateTextureTime(displayRender: DisplayRender?) {
        texturesAndDotsTime = CACurrentMediaTime()
        if allFrames < 100 {
            if texturesAndDotsTime - drawTime > delta - 0.002 {  // it is not in sync
                numberOfErrors += 1
            }
            if numberOfErrors == 3 {
                numberOfErrors += 1
                displayRender?.needToSync = true
            }
        }
    }

    func updateEncodeTime() {
        if debug {
            encodeTime = CACurrentMediaTime()
        }
    }

    func updateCommitTime(drawable: MTLDrawable) {
        if debug {
            commitTime = CACurrentMediaTime()
        }

        previousDrawables.append(drawable)

        if initScene2 {
            initSceneDrawable = drawable
            initScene2 = false
        }

        if previousDrawables.count > 5 {
            previousDrawables.removeFirst()
        }
    }

    func printFrameControl() {
        if debug {
            var text = "scene,trial,frameScene,frameTotal,initTime,endTime,duration,texturesAndDotsTime,encodeTime,"
            text += "commitTime,responded,measure,long"
            print(text)

            for f in frames where f.measure && f.frameTotal > 0 {
                print(String(f.scene) + "," + String(f.trial) + "," + String(f.frameScene) + "," +
                    String(f.frameTotal) + "," + String(f.initTime) + "," + String(f.endTime) + "," +
                    String(f.duration) + "," + String(f.texturesAndDotsTime) + "," + String(f.encodeTime) + "," +
                    String(f.commitTime) + "," + String(f.responded) + "," + String(f.measure) + "," + String(f.long))
            }
        }
    }
}
