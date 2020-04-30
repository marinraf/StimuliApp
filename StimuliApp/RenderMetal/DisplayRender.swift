//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import MetalKit
import GameKit
import CommonCrypto

var elapsed: Double = 0

// MARK: - Protocol
protocol DisplayRenderDelegate: class {

    func addBackButton(position: FixedXButton)

    func end()
    func clear()

    func drawText(text: TextObject)
    func deleteText(text: TextObject)
    func playVideo(video: VideoObject)
    func stopVideo()
    func playAudio(audio: AudioObject)
    func stopAudio()
    func playSineWaves(audio: [Float])
    func playSineWave()
    func stopSineWave()
    func showKeyboard(type: FixedKeyboard, inTitle: Bool)
    func settingTimeLabel()
    func settingKeyResponses()
}

// MARK: - DisplayRender
class DisplayRender {

    var device: MTLDevice
    var size: CGSize
    var previewScene: Bool
    weak var displayRenderDelegate: DisplayRenderDelegate?

    enum Status {
        case playing
        case stopped
        case plusButton
        case minusButton

        var toFloat: Float {
            switch self {
            case .playing: return 1
            case .stopped: return 0
            case .plusButton: return 1
            case .minusButton: return -1
            }
        }
    }

    //controlling things
    var timeInFrames: Int = 0
    var startRealTime: Double = 0
    var endRealTime: Double = 0
    var sectionNumber: Int = 0
    var randomSeed: Int = 1
    var responded: Bool = false
    var inactive: Bool = false
    var inactiveToMeasureFrame: Bool = false
    var status: Status = .playing

    var counter = 0

    var touching = false
    var userResponseTemp: Float?
    var objectsTouched: Int?

    var keyboard: Bool = false
    var keyboardType: FixedKeyboard = .normal
    var responseInTitle: Bool = false

    // MARK: - Init
    init(device: MTLDevice, size: CGSize, previewScene: Bool) {
        self.device = device
        self.size = size
        self.previewScene = previewScene

        initSceneZero()
    }

    func initSceneZero() {
        Task.shared.sectionTask = Task.shared.sectionZeroTask
        Task.shared.sceneTask = Task.shared.sectionZeroTask.sceneTasks[0]

        // in the first scene we give time to initialize the device and everything, so we use a queue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.displayRenderDelegate?.addBackButton(position: Task.shared.xButtonPosition)
        })
    }

    func initScene() {
        displayRenderDelegate?.clear()

        timeInFrames = 0
        counter = 0

        touching = false
        userResponseTemp = nil
        objectsTouched = nil
        responded = false

        let trial = Task.shared.sectionTask.currentTrial

        Task.shared.sceneTask = Task.shared.sectionTask.sceneTasks[Task.shared.sectionTask.sceneNumber]

        Task.shared.responseMovingObject = nil
        
        Task.shared.updateScene(device: device, trial: trial, status: status)

        Task.shared.userResponse = UserResponse()

        keyboard = Task.shared.sceneTask.responseType == .keyboard
        keyboardType = Task.shared.sceneTask.responseKeyboard
        responseInTitle = Task.shared.sceneTask.responseInTitle

        inactive = false
        inactiveToMeasureFrame = false

        displayRenderDelegate?.settingKeyResponses()

        displayRenderDelegate?.settingTimeLabel()

        displayRenderDelegate?.playSineWaves(audio: Task.shared.sceneTask.sineWaveFloats[trial])

        startRealTime = CACurrentMediaTime()
    }

    func update() -> Bool {
        guard !inactive else {
            return false
        }

        if timeInFrames == 0 {

        }

        if responded {
            responded = false
            changeDisplay(realTimeInFrames: timeInFrames)
        }
        
        updateLabel()

        let currentTrial = Task.shared.sectionTask.currentTrial

        let check = Task.shared.sceneTask.checkPoints[currentTrial][counter]

        if timeInFrames + 1 >= check.time && check.type == .endScene {
            displayRenderDelegate?.stopSineWave()
        }

        while timeInFrames >= Task.shared.sceneTask.checkPoints[currentTrial][counter].time {

            let action = Task.shared.sceneTask.checkPoints[currentTrial][counter].action
            let objectNumber = Task.shared.sceneTask.checkPoints[currentTrial][counter].objectNumber

            if startStop(action: action, objectNumber: objectNumber) {
                timeInFrames += 1
                return true
            } else {
                counter += 1
            }
        }

        Task.shared.updateData(device: device,
                               trial: Task.shared.sectionTask.currentTrial,
                               timeInFrames: timeInFrames,
                               status: status)

        if status == .playing {
            timeInFrames += 1
        } else {
            status = .stopped
        }
        return false
    }

    func reverse() {
        guard counter > 0 else { return }

        let currentTrial = Task.shared.sectionTask.currentTrial

        while timeInFrames < Task.shared.sceneTask.checkPoints[currentTrial][counter - 1].time {

            let action = Task.shared.sceneTask.checkPoints[currentTrial][counter - 1].action
            let objectNumber = Task.shared.sceneTask.checkPoints[currentTrial][counter - 1].objectNumber

            startStopReversed(action: action, objectNumber: objectNumber)
            counter -= 1
            if counter == 0 {
                break
            }
        }
    }

    private func updateLabel() {
        guard previewScene else { return }
        if timeInFrames % (Flow.shared.settings.frameRate / 2) == 0 {
            displayRenderDelegate?.settingTimeLabel()
        }
    }

    func startStop(action: SceneTask.Action, objectNumber: Int) -> Bool {
        let trial = Task.shared.sectionTask.currentTrial
        switch action {
        case .endScene:
            if keyboard {
                inactive = true
                inactiveToMeasureFrame = true
                displayRenderDelegate?.showKeyboard(type: keyboardType, inTitle: responseInTitle)
            } else {
                changeDisplay(realTimeInFrames: timeInFrames)
            }
            return true
        case .startText:
            displayRenderDelegate?.drawText(text: Task.shared.sceneTask.textObjects[trial][objectNumber])
            return false
        case .endText:
            displayRenderDelegate?.deleteText(text: Task.shared.sceneTask.textObjects[trial][objectNumber])
            return false
        case .startAudio:
            displayRenderDelegate?.playAudio(audio: Task.shared.sceneTask.audioObjects[trial][objectNumber])
            return false
        case .endAudio:
            displayRenderDelegate?.stopAudio()
            return false
        case .startVideo:
            displayRenderDelegate?.playVideo(video: Task.shared.sceneTask.videoObjects[trial][objectNumber])
            return false
        case .endVideo:
            displayRenderDelegate?.stopVideo()
            return false
        case .startSineWave:
            displayRenderDelegate?.playSineWave()
            return false
        case .endSineWave:
            displayRenderDelegate?.stopSineWave()
            return false
        }
    }

    func startStopReversed(action: SceneTask.Action, objectNumber: Int) {
        let trial = Task.shared.sectionTask.currentTrial
        switch action {
        case .endScene:
            break
        case .startText:
            displayRenderDelegate?.deleteText(text: Task.shared.sceneTask.textObjects[trial][objectNumber])
        case .endText:
            displayRenderDelegate?.drawText(text: Task.shared.sceneTask.textObjects[trial][objectNumber])
        case .startAudio:
            displayRenderDelegate?.stopAudio()
        case .endAudio:
            displayRenderDelegate?.playAudio(audio: Task.shared.sceneTask.audioObjects[trial][objectNumber])
        case .startVideo:
            displayRenderDelegate?.stopVideo()
        case .endVideo:
            displayRenderDelegate?.playVideo(video: Task.shared.sceneTask.videoObjects[trial][objectNumber])
        case .startSineWave:
            displayRenderDelegate?.stopSineWave()
        case .endSineWave:
            displayRenderDelegate?.playSineWave()
        }
    }

    func changeDisplay(realTimeInFrames: Int) {
        guard !previewScene else {
            changeToSection(sectionNumber: 0)
            return
        }
        inactive = true
        if Task.shared.sectionTask.sceneNumber < Task.shared.sectionTask.sceneTasks.count - 1 {
            changeToNextSceneInSection(realTimeInFrames: realTimeInFrames)
        } else {
            var exitLoop = false
            lastSceneOfSection(realTimeInFrames: realTimeInFrames)
            for condition in Task.shared.sectionTask.conditions where !exitLoop {
                guard let type = condition.type else {
                    if Task.shared.sectionTask.currentTrial + 1 < Task.shared.sectionTask.numberOfTrials {
                        changeToSection(sectionNumber: sectionNumber)
                    } else {
                        changeToSection(sectionNumber: condition.sectionNumber)
                    }
                    return
                }
                switch type {
                case .lastCorrect:
                    if Task.shared.sectionTask.last == 1 {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .lastIncorrect:
                    if Task.shared.sectionTask.last == 0 {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberCorrects:
                    if Task.shared.sectionTask.numberOfCorrects == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberIncorrects:
                    if Task.shared.sectionTask.numberOfIncorrects == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberOfResponses:
                    if Task.shared.sectionTask.numberOfResponded == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberOfTrials:
                    if Task.shared.sectionTask.currentTrial + 1 == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                }
            }
        }
    }

    func changeToNextSceneInSection(realTimeInFrames: Int) {
        Task.shared.sceneTask.saveSceneData(timeInFrames: realTimeInFrames,
                                            startTime: startRealTime,
                                            trial: Task.shared.sectionTask.currentTrial)
        Task.shared.sectionTask.sceneNumber += 1
        initScene()
    }

    func lastSceneOfSection(realTimeInFrames: Int) {
        Task.shared.sceneTask.saveSceneData(timeInFrames: realTimeInFrames,
                                            startTime: startRealTime,
                                            trial: Task.shared.sectionTask.currentTrial)
        Task.shared.sectionTask.sceneNumber = 0
        if Task.shared.sectionTask.last == 1 {
            Task.shared.sectionTask.numberOfCorrects += 1
            Task.shared.sectionTask.correctValue.append(1)
        } else {
            Task.shared.sectionTask.numberOfIncorrects += 1
            Task.shared.sectionTask.correctValue.append(0)
        }
    }

    func changeToSection(sectionNumber: Int) {
        Task.shared.sectionTask.saveSectionData()
        if Task.shared.sectionTask.currentTrial < Task.shared.sectionTask.numberOfTrials - 1 {
            Task.shared.sectionTask.currentTrial += 1
        } else {
            Task.shared.sectionTask.currentTrial = 0
        }

        if sectionNumber == -1 {
            inactive = true
            displayRenderDelegate?.end()
        } else {
            Task.shared.sectionTask = Task.shared.sectionTasks[sectionNumber]
            self.sectionNumber = sectionNumber
            initScene()
        }
    }
}
