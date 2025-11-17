//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import MetalKit
import UIKit
import AVKit
import AVFoundation
import SafariServices
import ARKit
import SceneKit

class DisplayViewController: UIViewController {

    var audioSystem = AudioSystem()

    var renderer: Renderer?
    var displayRender: DisplayRender?

    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer?
    var videoTag: Int = Constants.videoViewTag
    var addedViewsTag: [Int] = []
    var numberKeyboard = false
    var inTitle = false

    var screenSize: CGSize = UIScreen.main.bounds.size
    var x: CGFloat = 0
    var y: CGFloat = 0

    private let button = UIButton(type: .custom)
    private let topLeftMarkerImage = UIImageView()
    private let topRightMarkerImage = UIImageView()
    private let bottomLeftMarkerImage = UIImageView()
    private let bottomRightMarkerImage = UIImageView()
    
    private let buttonMargin: CGFloat = 25
    private let buttonSize: CGFloat = 55
    
    
//    var session: ARSession!
    

    @IBOutlet weak var metalView: MTKView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var textField: UITextField!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(animated)
    //        UIApplication.shared.isIdleTimerDisabled = true
    //
    //        let configuration = ARFaceTrackingConfiguration()
    //        if #available(iOS 13.0, *) {
    //            configuration.maximumNumberOfTrackedFaces = 1
    //            configuration.worldAlignment = .camera
    //        }
    //        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    //    }
    //
    //    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    //        if let currentFrame = session.currentFrame {
    //            for anchor in currentFrame.anchors {
    //                guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
    //                print(faceAnchor.transform[3][2])
    //            }
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        session = ARSession()
//        session.delegate = self
        
        self.hidesBottomBarWhenPushed = true

        Flow.shared.enterFullScreen()

        //audio
        audioSystem.setup(songs: Task.shared.audios.map({ $0.url }))
        audioSystem.begin()

        //brightness
        UIApplication.shared.isIdleTimerDisabled = true
        let brightness = pow(Flow.shared.settings.brightness, (1.0 / Constants.gammaPerBrightness))
        UIScreen.main.brightness = CGFloat(brightness - 0.01)
        UIScreen.main.brightness = CGFloat(brightness)
        
        //tracker
        Flow.shared.eyeTracker?.eyeTrackerDelegate = self
        Flow.shared.eyeTracker?.start()

        //metal device
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.framebufferOnly = false

        metalView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        metalView.preferredFramesPerSecond = Flow.shared.settings.frameRate
        guard let device = metalView.device else {
            fatalError("Device not created. Run on a physical device.")
        }

        //some tags
        metalView.tag = Constants.metalViewTag
        controlView.tag = Constants.controlViewTag

        //buttons and texts
        textField.isHidden = true

        //displayRender & renderer
        displayRender = DisplayRender(device: device, size: view.bounds.size, previewScene: false)
        displayRender?.displayRenderDelegate = self
        renderer = Renderer(device: device)
        renderer?.displayRender = displayRender
        renderer?.view = metalView
        renderer?.createThreadsBuffersAndTextures()
        metalView.delegate = renderer
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true

        view.frame = CGRect(x: x, y:y, width: screenSize.width, height: screenSize.height)

        switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .unknown {
        case .unknown:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
        case .portrait:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
        case .portraitUpsideDown:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
        case .landscapeLeft:
            AppUtility.lockOrientation(.landscapeLeft)
            Flow.shared.orientation = .landscapeLeft
        case .landscapeRight:
            AppUtility.lockOrientation(.landscapeRight)
            Flow.shared.orientation = .landscapeRight
        @unknown default:
            AppUtility.lockOrientation(.portrait)
            Flow.shared.orientation = .portrait
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Flow.shared.exitFullScreen()

        UIApplication.shared.isIdleTimerDisabled = false
        AppUtility.lockOrientation(.all)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

// MARK: - Extension functions
extension DisplayViewController: DisplayRenderDelegate {

    func pauseToSync() {
        displayRender?.inactive = true
        player?.pause()
        audioSystem.pauseAudio()
        Flow.shared.eyeTracker?.stopTracking()
        showAlertNeedToSync(resume: { _ in self.resumeFromPause() }, end: { _ in self.end() })
    }
    
    func pauseToWarn(error: ErrorTracker) {
        displayRender?.inactive = true
        player?.pause()
        audioSystem.pauseAudio()
        Flow.shared.eyeTracker?.stopTracking()
        switch error {
        case .no:
            break
        case .eyeTracker:
            showAlertFixationBroken(resume: { _ in self.resumeFromWarning() })
        case .distanceMin:
            showAlertDistanceBrokenClose(resume: { _ in self.resumeFromWarning() })
        case .distanceMax:
            showAlertDistanceBrokenFar(resume: { _ in self.resumeFromWarning() })
        case .distanceNan:
            showAlertDistanceBrokenNan(resume: { _ in self.resumeFromWarning() })
        }
    }

    func showFirstMessageTest() {
        displayRender?.inactive = true
        player?.pause()
        audioSystem.pauseAudio()
        Flow.shared.eyeTracker?.stopTracking()
        
        var shouldUseMacConfiguration = false
        if #available(iOS 14.0, *) {
            if ProcessInfo.processInfo.isiOSAppOnMac {
                shouldUseMacConfiguration = true
            }
        }
        
        if shouldUseMacConfiguration {
            showAlertFirstMessageMac(resume: { _ in self.resumeFromPauseFirst() }, end: { _ in self.end() })
        } else {
            showAlertFirstMessageTest(resume: { _ in self.resumeFromPauseFirst() }, end: { _ in self.end() })
        }
    }

    func addBackButton(position: FixedXButton,
                       markers: Bool,
                       markersSize: Int,
                       markersHorizontal: Int,
                       markersVertical: Int) {
        // If markers is true, add corner marker images only; if false, add main back button only
        if markers {
            // Configure common properties for all marker images
            let markerImages: [(UIImageView, String)] = [
                (topLeftMarkerImage, "marker1"),
                (topRightMarkerImage, "marker2"),
                (bottomLeftMarkerImage, "marker3"),
                (bottomRightMarkerImage, "marker4")
            ]
            markerImages.forEach { (imageView, imageName) in
                if imageView.superview == nil { self.controlView.addSubview(imageView) }
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.image = UIImage(named: imageName)
                imageView.contentMode = .scaleToFill
                imageView.widthAnchor.constraint(equalToConstant: CGFloat(markersSize)).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: CGFloat(markersSize)).isActive = true
            }
            // Top-left
            NSLayoutConstraint.activate([
                topLeftMarkerImage.topAnchor.constraint(equalTo: controlView.topAnchor,
                                                        constant: CGFloat(markersVertical)),
                topLeftMarkerImage.leftAnchor.constraint(equalTo: controlView.leftAnchor,
                                                         constant: CGFloat(markersHorizontal))
            ])
            // Top-right
            NSLayoutConstraint.activate([
                topRightMarkerImage.topAnchor.constraint(equalTo: controlView.topAnchor,
                                                         constant: CGFloat(markersVertical)),
                topRightMarkerImage.rightAnchor.constraint(equalTo: controlView.rightAnchor,
                                                           constant: -CGFloat(markersHorizontal))
            ])
            // Bottom-left
            NSLayoutConstraint.activate([
                bottomLeftMarkerImage.bottomAnchor.constraint(equalTo: controlView.bottomAnchor,
                                                              constant: -CGFloat(markersVertical)),
                bottomLeftMarkerImage.leftAnchor.constraint(equalTo: controlView.leftAnchor,
                                                            constant: CGFloat(markersHorizontal))
            ])
            // Bottom-right
            NSLayoutConstraint.activate([
                bottomRightMarkerImage.bottomAnchor.constraint(equalTo: controlView.bottomAnchor,
                                                               constant: -CGFloat(markersVertical)),
                bottomRightMarkerImage.rightAnchor.constraint(equalTo: controlView.rightAnchor,
                                                              constant: -CGFloat(markersHorizontal))
            ])
        }

        switch position {
        case .topLeft:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: controlView.topAnchor, constant: buttonMargin).isActive = true
            button.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: buttonMargin).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .topRight:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: controlView.topAnchor, constant: buttonMargin).isActive = true
            button.rightAnchor.constraint(equalTo: controlView.rightAnchor, constant: -buttonMargin).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .bottomLeft:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -buttonMargin).isActive = true
            button.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: buttonMargin).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .bottomRight:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -buttonMargin).isActive = true
            button.rightAnchor.constraint(equalTo: controlView.rightAnchor, constant: -buttonMargin).isActive = true
            button.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .noButton:
            break
        }
    }

    @objc func buttonAction(sender: UIButton!) {
        displayRender?.inactive = true
        pause()
    }

    func end() {
        Task.shared.previousSceneTask = Task.shared.sceneTask
        Flow.shared.initScene = true

        Flow.shared.eyeTracker?.stopTracking()
        Flow.shared.eyeTracker?.end()
        
        stopVideo()
        stopAudio(forceStop: true)

        switch Task.shared.preview {

        case .no:
            var offset: Double = Task.shared.scaleTime
            var slope: Double = 0
            var halfMinRtt: Double = 0
            var rse: Double = 0
            var numberOfSamples: Int = 0
            var neonLinearModel: Bool = false
            var neonSyncError: Bool = false
            var calculationsError: Bool = false
            
            _Concurrency.Task {
                let useNeon = Task.shared.testUsesNeonSync
                var neonResult: NeonResult?
                
                if useNeon {
                    neonResult = await Task.shared.neon?.stopAndAnalyze()
                    if let neonResult = neonResult {
                        offset = neonResult.intercept / 1000 // regression was done in ms we want seconds
                        slope = neonResult.slope  // slope doesn't depend on the unit
                        halfMinRtt = neonResult.halfMinRtt  //half of the min rtt in ms
                        rse = neonResult.rse  // rse in ms
                        numberOfSamples = neonResult.numberOfSamples
                        neonLinearModel = true
                        neonSyncError = false
                    } else {
                        calculationsError = true
                    }
                    
                }
                
                showAlertTestIsFinished(action: { _ in
                    Task.shared.saveTestAsResult(offset: offset,
                                                 slope: slope,
                                                 halfMinRtt: halfMinRtt,
                                                 rse: rse,
                                                 numberOfSamples: numberOfSamples,
                                                 neonLinearModel: neonLinearModel,
                                                 neonSyncError: neonSyncError,
                                                 calculationsError: calculationsError)
                    Flow.shared.initTabControllerMenu()
                })
            }
            
        case .previewTest:
            showAlertTestIsFinishedPreview(action: { _ in
                Flow.shared.navigateBack()
            }, action2: { _ in
                if let url = URL(string: Texts.frameRateWeb) {
                    let svc = SFSafariViewController(url: url)
                    let goBack = {
                        Flow.shared.navigateBack()
                    }
                    self.present(svc, animated: true, completion: goBack)
                }
            })
        case .previewScene, .previewStimulus, .variablesSection:
            Flow.shared.navigateBack()
        }
    }

    func clear() {
        stopVideo()
        for i in addedViewsTag {
            if let viewWithTag = self.view.viewWithTag(i) {
                viewWithTag.removeFromSuperview()
                addedViewsTag = addedViewsTag.filter({ $0 != i })
            }
        }
        metalView.tag = Constants.metalViewTag
    }

    func pause() {
        player?.pause()
        audioSystem.pauseAudio()
        Flow.shared.eyeTracker?.stopTracking()
        switch Task.shared.preview {
        case .no, .previewTest:
            showAlertCancelTest(resume: { _ in self.resumeFromPause() }, end: { _ in self.end() })
        case .previewScene, .previewStimulus, .variablesSection:
            end()
        }
    }

    func drawText(text: TextObject) {

        guard text.activated else { return }

        let width = self.view.bounds.size.width
        let height = self.view.bounds.size.height

        let posX = text.positionX / 2 + width / 2
        let posY = -text.positionY / 2 + height / 2

        let label = UILabel(frame: CGRect(x: width / 2, y: height / 2, width: width, height: height))

        label.tag = text.tag
        addedViewsTag.append(label.tag)
        label.center = CGPoint(x: posX, y: posY)
        label.textAlignment = .center
        label.text = text.text
        label.textColor = UIColor(red: text.red, green: text.green, blue: text.blue, alpha: 1.0)
        label.font = text.font
        let textView = label as UIView

        insertView(textView, in: self.view)
    }

    func deleteText(text: TextObject) {
        if let viewWithTag = self.view.viewWithTag(text.tag) {
            viewWithTag.removeFromSuperview()
            addedViewsTag = addedViewsTag.filter({ $0 != text.tag })
        }
    }

    private func insertView(_ viewToInsert: UIView, in view: UIView) {
        let subviewsInOrder = view.subviews.sorted(by: { $0.tag < $1.tag })
        for element in subviewsInOrder where viewToInsert.tag < element.tag {
            self.view.insertSubview(viewToInsert, belowSubview: element)
            return
        }
    }

    func showKeyboard(type: FixedKeyboard, inTitle: Bool) {
        
        self.inTitle = inTitle
        player?.pause()
        audioSystem.pauseAudio()
        Flow.shared.eyeTracker?.stopTracking()
        textField.isHidden = false
        numberKeyboard = type == .numeric ? true : false
        textField.text = ""
        textField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        textField.inputAssistantItem.trailingBarButtonGroups.removeAll()
        textField.becomeFirstResponder()
    }

    func resumeFromPause() {
        displayRender?.inactive = false
        player?.play()
        audioSystem.resumeAudio()
        Flow.shared.eyeTracker?.startTracking()
    }
    
    func resumeFromWarning() {
        if Task.shared.sceneTask.trackerResponses.count > Task.shared.sectionTask.currentTrial {
            Task.shared.sceneTask.trackerResponses[Task.shared.sectionTask.currentTrial].errors = []
        }
        if Task.shared.sceneTask.distanceResponses.count > Task.shared.sectionTask.currentTrial {
            Task.shared.sceneTask.distanceResponses[Task.shared.sectionTask.currentTrial].errorMaxs = []
            Task.shared.sceneTask.distanceResponses[Task.shared.sectionTask.currentTrial].errorMins = []
            Task.shared.sceneTask.distanceResponses[Task.shared.sectionTask.currentTrial].errorNans = []
        }
        displayRender?.inactive = false
        player?.play()
        audioSystem.resumeAudio()
        Flow.shared.eyeTracker?.startTracking()
        Task.shared.warningTracker = true
        Task.shared.warningTrackerPause = .no
    }

    func resumeFromPauseFirst() {
        displayRender?.inactive = false
        player?.play()
        audioSystem.resumeAudio()
        Flow.shared.eyeTracker?.startTracking()
    }

    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        player = AVPlayer(url: videoUrl)
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspect
        view.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        view.layer.addSublayer(layer)
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
        if let viewWithTag = self.view.viewWithTag(videoTag) {
            viewWithTag.removeFromSuperview()
            addedViewsTag = addedViewsTag.filter({ $0 != videoTag })
        }
    }

    func playVideo(video: VideoObject) {

        guard video.activated else { return }

        guard let videoToPlay = video.url else { return }

        let videoView = UIView(frame: UIScreen.main.bounds)
        videoView.tag = video.tag
        videoTag = videoView.tag
        addedViewsTag.append(videoView.tag)

        insertView(videoView, in: self.view)

        addVideoPlayer(videoUrl: videoToPlay, to: videoView)
        player?.play()

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }

    func stopVideo() {
        player?.pause()
        player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
        if let viewWithTag = self.view.viewWithTag(videoTag) {
            viewWithTag.removeFromSuperview()
            addedViewsTag = addedViewsTag.filter({ $0 != videoTag })
        }
    }

    func playAudios(audio: [Float]) {
        if audio[AudioValues.numberOfAudios] > 0.5 {
            audioSystem.playAudios(audio: audio)
        } else {
            audioSystem.stopAudio(forceStop: false)
        }
    }

    func settingKeyResponses() {
         _ = keyCommands
    }

    func playAudio() {}

    func stopOneAudio() {}

    func stopAudio(forceStop: Bool) {
        audioSystem.stopAudio(forceStop: forceStop)
    }

    func settingTimeLabel() {}
}

// MARK: - Functions touches we will use in Scene or scenes
extension DisplayViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if Task.shared.sceneTask.responseType == .keyboard {
            self.view.endEditing(true)
        } else {
            displayRender?.touchesBegan(view, touches: touches, with: event)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayRender?.touchesMoved(view, touches: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        displayRender?.touchesEnded(view, touches: touches, with: event)
    }
}

// MARK: - Texfield functions
extension DisplayViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.keyboardType = numberKeyboard ? UIKeyboardType.numbersAndPunctuation : UIKeyboardType.default
        button.isHidden = true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            Task.shared.userResponse.string = text
            if inTitle {
                Task.shared.responseKeyboard = text
            }
            displayRender?.inactive = false
            Task.shared.userResponse.clocks.append(CACurrentMediaTime())
            stopAudio(forceStop: false)
            displayRender?.responded = true
            textField.isHidden = true
            button.isHidden = false
            Flow.shared.eyeTracker?.startTracking()
        }
        return true
    }
}

// MARK: - Key responses
extension DisplayViewController {

    override var keyCommands: [UIKeyCommand]? {
        if Task.shared.sceneTask.responseKeys.isEmpty {
            return []
        } else {
            return [
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[0].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction0)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[1].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction1)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[2].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction2)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[3].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction3)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[4].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction4)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[5].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction5)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[6].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction6)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[7].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction7)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[8].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction8)),
                UIKeyCommand(input: Task.shared.sceneTask.responseKeys[9].0,
                             modifierFlags: [],
                             action: #selector(self.responseAction9))
            ]
        }
    }

    @objc func responseAction0() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[0].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction1() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[1].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction2() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[2].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction3() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[3].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction4() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[4].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction5() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[5].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction6() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[6].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction7() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[7].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction8() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[8].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }

    @objc func responseAction9() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[9].1
        let time = CACurrentMediaTime()
        
        let trial = Task.shared.sectionTask.currentTrial
        let array = Task.shared.sceneTask.realStartTime
        guard (0 <= trial && trial < array.count) else { return }
        let time0 = time - array[trial]
        
        Task.shared.sceneTask.badTiming = time0 < Task.shared.sceneTask.responseStart
            || time0 > Task.shared.sceneTask.responseEnd
        guard !Task.shared.sceneTask.badTiming || Task.shared.sceneTask.responseOutWindow else { return }
        Task.shared.userResponse.clocks.append(time)
        stopAudio(forceStop: false)
        displayRender?.responded = true
    }
}


extension DisplayViewController : TrackerOnViewDelegate {
    
    func onInitialized(error: Bool) {}
    func onCalibrationProgress(progress: Double) {}
    func onCalibrationNextPoint(x: Double, y: Double) {}
    func onCalibrationFinished(calibrationData : [Double]) {}
    
    func onGaze(gazeX: Double, gazeY: Double,
                clock: Double, isTracking: Bool) {

        if (Task.shared.testUsesTrackerSeeSo || Task.shared.testUsesTrackerARKit) && Task.shared.warningTrackerPause == .no {

            let trial = Task.shared.sectionTask.currentTrial

            guard trial > 0 || Task.shared.sceneTask.trackerResponses.count < 2 else { return }

            if (!Task.shared.sceneTask.trackerResponses.isEmpty) {
                if (Task.shared.sceneTask.trackerResponses.count < trial + 1) {
                    Task.shared.sceneTask.trackerResponses.append(TrackerResponse())
                }

                let coordinate = Task.shared.trackerCoordinates
                let unit1 = Task.shared.trackerFirstUnit
                let unit2 = Task.shared.trackerSecondUnit
                
                let x = Float(gazeX - screenSize.width / 2) * Flow.shared.settings.retina
                let y = Float(-gazeY + screenSize.height / 2) * Flow.shared.settings.retina

                let polarVars = AppUtility.cartesianToPolar(xPos: x, yPos: y)
                let radius = polarVars.0
                let angle = polarVars.1

                switch coordinate {
                case .cartesian:
                    let xUnit = x / unit1.factor
                    let yUnit = y / unit2.factor

                    Task.shared.sceneTask.trackerResponses[trial].xGazes.append(xUnit)
                    Task.shared.sceneTask.trackerResponses[trial].yGazes.append(yUnit)
                    Task.shared.sceneTask.trackerResponses[trial].clocks.append(clock)

                case .polar:
                    let radiusUnit = radius / unit1.factor
                    let angleUnit = angle / unit2.factor

                    Task.shared.sceneTask.trackerResponses[trial].radiusGazes.append(radiusUnit)
                    Task.shared.sceneTask.trackerResponses[trial].angleGazes.append(angleUnit)
                    Task.shared.sceneTask.trackerResponses[trial].clocks.append(clock)
                }
                
                if Task.shared.sceneTask.gazeFixation {
                    if radius > Task.shared.sceneTask.maxGazeErrorInPixels || radius.isNaN {
                        Task.shared.sceneTask.trackerResponses[trial].errors.append(1)
                    } else {
                        Task.shared.sceneTask.trackerResponses[trial].errors.append(0)
                    }

                    if Task.shared.sceneTask.trackerResponses[trial].errors.reduce(0, +) >= Constants.numberOfTrackingErrors {
                        Task.shared.warningTrackerPause = .eyeTracker
                        Task.shared.sceneTask.trackerResponses[trial].errors = []
                    }
                }
            }
        }
    }
    
    func onFace(z: Float, clock: Double) {
        
        if (Task.shared.testUsesTrackerSeeSo || Task.shared.testUsesTrackerARKit) && Task.shared.warningTrackerPause == .no {
            
            let trial = Task.shared.sectionTask.currentTrial

            guard trial > 0 || Task.shared.sceneTask.distanceResponses.count < 2 else { return }

            if (!Task.shared.sceneTask.distanceResponses.isEmpty) {
                if (Task.shared.sceneTask.distanceResponses.count < trial + 1) {
                    Task.shared.sceneTask.distanceResponses.append(DistanceResponse())
                }

                let unit = Task.shared.distanceUnit

                var zUnit = z
                if unit == .inch {
                    zUnit = z / Constants.cmsInInch
                }

                Task.shared.sceneTask.distanceResponses[trial].zDistances.append(zUnit)
                Task.shared.sceneTask.distanceResponses[trial].clocks.append(clock)


                if Task.shared.sceneTask.distanceFixation {
                    if z > Task.shared.sceneTask.maxDistanceErrorInCm {
                        Task.shared.sceneTask.distanceResponses[trial].errorMaxs.append(1)
                        Task.shared.sceneTask.distanceResponses[trial].errorMins.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorNans.append(0)
                    } else if z < Task.shared.sceneTask.minDistanceErrorInCm {
                        Task.shared.sceneTask.distanceResponses[trial].errorMaxs.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorMins.append(1)
                        Task.shared.sceneTask.distanceResponses[trial].errorNans.append(0)
                    } else if z.isNaN {
                        Task.shared.sceneTask.distanceResponses[trial].errorMaxs.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorMins.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorNans.append(1)
                    } else {
                        Task.shared.sceneTask.distanceResponses[trial].errorMaxs.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorMins.append(0)
                        Task.shared.sceneTask.distanceResponses[trial].errorNans.append(0)
                    }

                    if Task.shared.sceneTask.distanceResponses[trial].errorMaxs.reduce(0, +) >= Constants.numberOfTrackingErrors {
                        Task.shared.warningTrackerPause = .distanceMax
                        Task.shared.sceneTask.distanceResponses[trial].errorMaxs = []
                    } else if Task.shared.sceneTask.distanceResponses[trial].errorMins.reduce(0, +) >= Constants.numberOfTrackingErrors {
                        Task.shared.warningTrackerPause = .distanceMin
                        Task.shared.sceneTask.distanceResponses[trial].errorMins = []
                    } else if Task.shared.sceneTask.distanceResponses[trial].errorNans.reduce(0, +) >= Constants.numberOfTrackingErrors {
                        Task.shared.warningTrackerPause = .distanceNan
                        Task.shared.sceneTask.distanceResponses[trial].errorNans = []
                    }
                }
            }
        }
    }

    func saveCalibrationData() {}
}

