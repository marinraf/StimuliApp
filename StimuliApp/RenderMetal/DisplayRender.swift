//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import MetalKit
import GameKit
import CommonCrypto

var elapsed: Double = 0

// MARK: - Protocol
protocol DisplayRenderDelegate: AnyObject {

    func addBackButton(position: FixedXButton)

    func end()
    func clear()

    func drawText(text: TextObject)
    func deleteText(text: TextObject)
    func playVideo(video: VideoObject)
    func stopVideo()
    func playAudios(audio: [Float])
    func playAudio()
    func stopAudio(forceStop: Bool)
    func stopOneAudio()
    func showKeyboard(type: FixedKeyboard, inTitle: Bool)
    func settingTimeLabel()
    func settingKeyResponses()
    func showFirstMessageTest()
    func pauseToSync()
    func pauseToWarn(error: ErrorTracker)
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
    var sectionNumber: Int = 0
    var randomSeed: Int = 1
    var responded: Bool = false
//    var badTiming: Bool = false
    var inactive: Bool = false
    var status: Status = .playing

    var counter = 0

    var touching = false
    var userResponseTemp: Float?
    var objectsTouched: Int?

    var keyboard: Bool = false
    var keyboardType: FixedKeyboard = .normal
    var responseInTitle: Bool = false

    var needToSync: Bool = false

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

        if Flow.shared.settings.device.type != .mac {
            switch Task.shared.preview {
            case .no:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.displayRenderDelegate?.showFirstMessageTest()
                })
            default:
                break
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.displayRenderDelegate?.showFirstMessageTest()
            })
        }
    }

    func initScene() {

        Flow.shared.frameControl.initScene = true

        displayRenderDelegate?.clear()

        timeInFrames = 0
        counter = 0

        touching = false
        userResponseTemp = nil
        objectsTouched = nil
        responded = false

        let trial = Task.shared.sectionTask.currentTrial

        Task.shared.sceneTask = Task.shared.sectionTask.sceneTasks[Task.shared.sectionTask.sceneNumber]
        
        if Task.shared.testUsesTrackerSeeSo {
            if (trial == 0) {
                Task.shared.sceneTask.trackerResponses.append(TrackerResponse())
                Task.shared.sceneTask.distanceResponses.append(DistanceResponse())
            }
        } else if Task.shared.testUsesTrackerARKit {
            if (trial == 0) {
                Task.shared.sceneTask.distanceResponses.append(DistanceResponse())
            }
        }

        Task.shared.responseMovingObject = nil
        
        Task.shared.updateScene(device: device, trial: trial, status: status)

        Task.shared.userResponse = UserResponse()

        keyboard = Task.shared.sceneTask.responseType == .keyboard
        keyboardType = Task.shared.sceneTask.responseKeyboard
        responseInTitle = Task.shared.sceneTask.responseInTitle

        inactive = false
        Flow.shared.frameControl.measure = true

        displayRenderDelegate?.settingKeyResponses()

        displayRenderDelegate?.settingTimeLabel()
        
        displayRenderDelegate?.playAudios(audio: Task.shared.sceneTask.audioFloats[trial])
    }

    func update() -> Bool {
        guard !inactive else {
            return false
        }

        if needToSync {
            needToSync = false
            displayRenderDelegate?.pauseToSync()
        }

        if responded {
            responded = false
            changeDisplay(realTimeInFrames: timeInFrames)
        }
        
        if (Task.shared.testUsesTrackerSeeSo || Task.shared.testUsesTrackerARKit) && Task.shared.warningTrackerPause != .no {
            displayRenderDelegate?.pauseToWarn(error: Task.shared.warningTrackerPause)
        }
        
        if Task.shared.testUsesTrackerSeeSo || Task.shared.testUsesTrackerARKit {
            if Task.shared.warningTracker {
                Task.shared.sectionTask.respondedInTime = false
                changeDisplay(realTimeInFrames: timeInFrames)
                Task.shared.warningTracker = false
            }
        }
        
        updateLabel()

        let currentTrial = Task.shared.sectionTask.currentTrial

        while timeInFrames >= Task.shared.sceneTask.checkPoints[currentTrial][counter].time {

            let action = Task.shared.sceneTask.checkPoints[currentTrial][counter].action
            let objectNumber = Task.shared.sceneTask.checkPoints[currentTrial][counter].objectNumber

            if startStop(action: action, objectNumber: objectNumber) {
                if status != .stopped {
                    timeInFrames += 1
                }
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
                Flow.shared.frameControl.measure = false
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
        case .startVideo:
            displayRenderDelegate?.playVideo(video: Task.shared.sceneTask.videoObjects[trial][objectNumber])
            return false
        case .endVideo:
            displayRenderDelegate?.stopVideo()
            return false
        case .startSound:
            displayRenderDelegate?.playAudio()
            return false
        case .endSound:
            displayRenderDelegate?.stopOneAudio()
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
        case .startVideo:
            displayRenderDelegate?.stopVideo()
        case .endVideo:
            displayRenderDelegate?.playVideo(video: Task.shared.sceneTask.videoObjects[trial][objectNumber])
        case .startSound:
            displayRenderDelegate?.stopOneAudio()
        case .endSound:
            displayRenderDelegate?.playAudio()
        }
    }

    func changeDisplay(realTimeInFrames: Int) {
        guard !previewScene else {
            changeToSection(sectionNumber: 0)
            return
        }
        inactive = true
        if Task.shared.sectionTask.sceneNumber < Task.shared.sectionTask.sceneTasks.count - 1 && !Task.shared.warningTracker {
            changeToNextSceneInSection()
        } else {
            var exitLoop = false
            lastSceneOfSection()
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
                case .lastResponded:
                    if Task.shared.sectionTask.respondedInTime {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .lastNotResponded:
                    if !Task.shared.sectionTask.respondedInTime {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberOfNotResponses:
                    if Task.shared.sectionTask.numberOfNotRespondedInTime == condition.n {
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
                    if Task.shared.sectionTask.numberOfRespondedInTime == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .numberOfTrials:
                    if Task.shared.sectionTask.currentTrial + 1 == condition.n {
                        changeToSection(sectionNumber: condition.sectionNumber)
                        exitLoop = true
                    }
                case .biggerAccuracy:
                    let totalTrials = Task.shared.sectionTask.currentTrial + 1
                    let n = condition.n
                    if totalTrials % n == 0 {
                        let accuracy = Float(Task.shared.sectionTask.correctValue.suffix(n).reduce(0, +)) / Float(n)
                        if accuracy + Constants.epsilon >= condition.a {
                            changeToSection(sectionNumber: condition.sectionNumber)
                            exitLoop = true
                        }
                    }
                case .smallerAccuracy:
                    let totalTrials = Task.shared.sectionTask.currentTrial + 1
                    let n = condition.n
                    if totalTrials % n == 0 {
                        let accuracy = Float(Task.shared.sectionTask.correctValue.suffix(n).reduce(0, +)) / Float(n)
                        if accuracy < condition.a {
                            changeToSection(sectionNumber: condition.sectionNumber)
                            exitLoop = true
                        }
                    }
                }
            }
        }
    }

    func changeToNextSceneInSection() {
//        print(self.timeInFrames, " change scene time: ", CACurrentMediaTime())
//        print(timeInFrames, " init scene 2 time: ", Flow.shared.frameControl.initSceneTimeReal)
                
        print(CACurrentMediaTime(), "- escena:", Task.shared.previousSceneTask.name, "end_time:", Flow.shared.frameControl.initSceneTimeReal, "timeInFrame:", timeInFrames)
        print(CACurrentMediaTime(), "- escena:", Task.shared.sceneTask.name, "init_time:", Flow.shared.frameControl.initSceneTimeReal, "timeInFrame:", timeInFrames)
        
        Task.shared.previousSceneTask.saveSceneTime(time: Flow.shared.frameControl.initSceneTimeReal)
        Task.shared.previousSceneTask = Task.shared.sceneTask
        Task.shared.sceneTask.saveSceneData(startTimeReal: Flow.shared.frameControl.initSceneTimeReal,
                                            trial: Task.shared.sectionTask.currentTrial)
        Task.shared.sectionTask.sceneNumber += 1
        initScene()
    }

    func lastSceneOfSection() {
        //        print(self.timeInFrames, " change scene time: ", CACurrentMediaTime())
        //        print(timeInFrames, " init scene 2 time: ", Flow.shared.frameControl.initSceneTimeReal)
                        
        print(CACurrentMediaTime(), "- escena:", Task.shared.previousSceneTask.name, "end_time:", Flow.shared.frameControl.initSceneTimeReal, "timeInFrame:", timeInFrames)
        print(CACurrentMediaTime(), "- escena:", Task.shared.sceneTask.name, "init_time:", Flow.shared.frameControl.initSceneTimeReal, "timeInFrame:", timeInFrames)
        
        Task.shared.previousSceneTask.saveSceneTime(time: Flow.shared.frameControl.initSceneTimeReal)
        Task.shared.previousSceneTask = Task.shared.sceneTask
        Task.shared.sceneTask.saveSceneData(startTimeReal: Flow.shared.frameControl.initSceneTimeReal,
                                            trial: Task.shared.sectionTask.currentTrial)
        
        let numberOfTrials = Task.shared.sectionTask.sceneTasks[0].realStartTime.count
        
        for sceneTask in Task.shared.sectionTask.sceneTasks {
            while sceneTask.realStartTime.count < numberOfTrials {
                sceneTask.realStartTime.append(Double.nan)
                sceneTask.realEndTime.append(Double.nan)
            }
        }
        if Task.shared.testUsesTrackerSeeSo {
            for sceneTask in Task.shared.sectionTask.sceneTasks {
                while sceneTask.trackerResponses.count < numberOfTrials {
                    sceneTask.trackerResponses.append(TrackerResponse())
                }
                while sceneTask.distanceResponses.count < numberOfTrials {
                    sceneTask.distanceResponses.append(DistanceResponse())
                }
                while sceneTask.userResponses.count < numberOfTrials {
                    sceneTask.userResponses.append(UserResponse())
                }
            }
        } else if Task.shared.testUsesTrackerARKit {
            for sceneTask in Task.shared.sectionTask.sceneTasks {
                while sceneTask.distanceResponses.count < numberOfTrials {
                    sceneTask.distanceResponses.append(DistanceResponse())
                }
                while sceneTask.userResponses.count < numberOfTrials {
                    sceneTask.userResponses.append(UserResponse())
                }
            }
        }
        
        Task.shared.sectionTask.sceneNumber = 0

        if Task.shared.sectionTask.respondedInTime {
            Task.shared.sectionTask.numberOfRespondedInTime += 1
            Task.shared.sectionTask.respondedValue.append(1)
        } else {
            Task.shared.sectionTask.numberOfNotRespondedInTime += 1
            Task.shared.sectionTask.respondedValue.append(0)
            if Task.shared.sectionTask.defaultValueNoResponse == nil || Task.shared.sectionTask.respondedOutTime {
                Task.shared.sectionTask.last = 0
            }
        }

        if Task.shared.sectionTask.last == 1 {
            Task.shared.sectionTask.numberOfCorrects += 1
            Task.shared.sectionTask.correctValue.append(1)
        } else {
            Task.shared.sectionTask.numberOfIncorrects += 1
            Task.shared.sectionTask.correctValue.append(0)
        }

    }

    func changeToSection(sectionNumber: Int) {
        Task.shared.sectionTask.respondedInTime = true
        Task.shared.sectionTask.respondedOutTime = false

        if Task.shared.sectionTask.currentTrial < Task.shared.sectionTask.numberOfTrials - 1 {
            Task.shared.sectionTask.currentTrial += 1
        } else {
            Task.shared.sectionTask.currentTrial = 0
        }

        Task.shared.updateDependentVariableTrial()

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
