//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import MetalKit
import UIKit
import AVKit
import AVFoundation
import SafariServices

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

    let button = UIButton(type: .custom)

    @IBOutlet weak var metalView: MTKView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var textField: UITextField!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print(Flow.shared.settings.brightness)
        Flow.shared.enterFullScreen()

        //audio
        audioSystem.setup()
        audioSystem.begin()

        //brightness
        UIApplication.shared.isIdleTimerDisabled = true
        UIScreen.main.brightness = CGFloat(Flow.shared.settings.brightness - 0.01)
        UIScreen.main.brightness = CGFloat(Flow.shared.settings.brightness)

        //metal device
        metalView.device = MTLCreateSystemDefaultDevice()
        metalView.framebufferOnly = false

        if Flow.shared.settings.device.type == .mac {
            screenSize = CGSize(width: CGFloat(Flow.shared.settings.width) / UIScreen.main.scale,
                                height: CGFloat(Flow.shared.settings.height) / UIScreen.main.scale)
        }

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

        var size = view.bounds.size
        view.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        size = view.bounds.size

        if size.width >= size.height {
            AppUtility.lockOrientation(.landscape)
        } else {
            AppUtility.lockOrientation(.portrait)
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

    func addBackButton(position: FixedXButton) {

        switch position {
        case .topLeft:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 30).isActive = true
            button.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: 30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 55).isActive = true
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .topRight:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 30).isActive = true
            button.rightAnchor.constraint(equalTo: controlView.rightAnchor, constant: -30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 55).isActive = true
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .bottomLeft:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -30).isActive = true
            button.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: 30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 55).isActive = true
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .bottomRight:
            self.controlView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: controlView.bottomAnchor, constant: -30).isActive = true
            button.rightAnchor.constraint(equalTo: controlView.rightAnchor, constant: -30).isActive = true
            button.widthAnchor.constraint(equalToConstant: 55).isActive = true
            button.heightAnchor.constraint(equalToConstant: 55).isActive = true
            button.setImage(UIImage(named: "cancel"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        case .noButton:
            break
        }
    }

    @objc func buttonAction(sender: UIButton!) {
        displayRender?.inactive = true
        displayRender?.inactiveToMeasureFrame = true
        pause()
    }

    func end() {
        stopAudio()
        stopVideo()

        Task.shared.saveTaskDataTime()

        switch Task.shared.preview {

        case .no:
            showAlertTestIsFinished(action: { _ in
                Flow.shared.initTabControllerMenu()
            })
            Task.shared.saveTestAsResult()
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
        stopAudio()
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
        audioSystem.pauseSong()
        audioSystem.pauseSound()
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
        audioSystem.pauseSong()
        audioSystem.pauseSound()
        textField.isHidden = false
        numberKeyboard = type == .numeric ? true : false
        textField.text = ""
        textField.inputAssistantItem.leadingBarButtonGroups.removeAll()
        textField.inputAssistantItem.trailingBarButtonGroups.removeAll()
        textField.becomeFirstResponder()
    }

    func resumeFromPause() {
        displayRender?.inactive = false
        displayRender?.inactiveToMeasureFrame = false
        player?.play()
        audioSystem.resumeSong()
        audioSystem.resumeSound()
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

    func playAudio(audio: AudioObject) {
        guard audio.activated else { return }

        guard let audioToPlay = audio.url else { return }
        audioSystem.playSong(song: audioToPlay)
        audioPlayer = audioSystem.audioPlayer
    }

    func stopAudio() {
        audioSystem.stopSong()
    }

    func playSineWaves(audio: [Float]) {
        if audio[SineWaveValues.numberOfAudios] > 0.5 {
            audioSystem.playSound(audio: audio)
        } else {
            audioSystem.stopSound()
        }
    }

    func settingKeyResponses() {
         _ = keyCommands
    }

    func playSineWave() {}

    func stopSineWave() {
        audioSystem.stopSound()
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
            displayRender?.inactiveToMeasureFrame = false
            let startTime = displayRender?.startRealTime ?? 0
            Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
            displayRender?.responded = true
            textField.isHidden = true
            button.isHidden = false
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
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction1() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[1].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction2() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[2].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction3() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[3].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction4() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[4].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction5() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[5].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction6() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[6].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction7() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[7].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction8() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[8].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }

    @objc func responseAction9() {
        Task.shared.userResponse.string = Task.shared.sceneTask.responseKeys[9].1
        let startTime = displayRender?.startRealTime ?? 0
        Task.shared.userResponse.clocks.append(CACurrentMediaTime() - startTime)
        displayRender?.responded = true
    }
}
