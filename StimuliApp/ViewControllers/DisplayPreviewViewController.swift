//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation
import MetalKit
import UIKit
import AVKit
import AVFoundation

class DisplayPreviewViewController: UIViewController {

    var numberOfVideos: Int = 0
    var numberOfAudios: Int = 0

    var numberOfPlayables: Int {
        return numberOfVideos + numberOfAudios
    }

    var renderer: Renderer?
    var displayRender: DisplayRender?

    var videoTag: Int = Constants.videoViewTag
    var addedViewsTag: [Int] = []
    var numberKeyboard = false

    var inactivation = true

    var screenSize: CGSize = UIScreen.main.bounds.size

    let button = UIButton(type: .custom)

    @IBOutlet weak var metalView: MTKView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playStopButton: UIButton!
    @IBOutlet weak var trialMinusButton: UIButton!
    @IBOutlet weak var trialPlusButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var frameMinusButton: UIButton!
    @IBOutlet weak var framePlusButton: UIButton!

    @IBOutlet weak var playingText: UITextView!
    @IBOutlet weak var timeText: UITextView!

    @IBAction func frameMinusPressed(_ sender: Any) {
        guard let timeInFrames = displayRender?.timeInFrames else { return }
        if timeInFrames > 0 {
            displayRender?.timeInFrames -= 1
            displayRender?.status = .minusButton
            displayRender?.reverse()
        }
        settingTimeLabel()
    }

    @IBAction func framePlusPressed(_ sender: Any) {
        displayRender?.timeInFrames += 1
        displayRender?.status = .plusButton
        settingTimeLabel()
    }

    @IBAction func restartPressed(_ sender: Any) {
        Task.shared.sectionTask.currentTrial = 0
        inactivation = true
        displayRender?.initScene()
    }

    @IBAction func trialMinusPressed(_ sender: Any) {
        Task.shared.sectionTask.currentTrial -= 1
        if Task.shared.sectionTask.currentTrial < 0 {
            Task.shared.sectionTask.currentTrial = 0
        }
        inactivation = true
        displayRender?.initScene()
    }

    @IBAction func trialPlusPressed(_ sender: Any) {
        Task.shared.sectionTask.currentTrial += 1
        if Task.shared.sectionTask.currentTrial >= Task.shared.sectionTask.numberOfTrials {
            Task.shared.sectionTask.currentTrial = 0
        }
        inactivation = true
        displayRender?.initScene()
    }

    @IBAction func playStopPressed(_ sender: Any) {

        guard let playing = displayRender?.status else { return }

        settingTimeLabel()

        if playing == .playing {
            settingStopped()
            displayRender?.status = .stopped
        } else {
            settingPlaying()
            displayRender?.status = .playing
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Flow.shared.enterFullScreen()

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

        //displayRender & renderer
        displayRender = DisplayRender(device: device, size: view.bounds.size, previewScene: true)
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
        settingPlayingLabel()
        settingHide()
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

    func settingPlayingLabel() {
        if numberOfPlayables > 0 {
            playingText.isHidden = false
        } else {
            playingText.isHidden = true
        }
    }

    func settingHide() {
        timeText.isHidden = true
        playStopButton.isHidden = true
        trialPlusButton.isHidden = true
        trialMinusButton.isHidden = true
        framePlusButton.isHidden = true
        frameMinusButton.isHidden = true
        restartButton.isHidden = true
    }

    func settingPlaying() {
        timeText.isHidden = false
        playStopButton.isHidden = false
        trialPlusButton.isHidden = true
        trialMinusButton.isHidden = true
        framePlusButton.isHidden = true
        frameMinusButton.isHidden = true
        restartButton.isHidden = true
        playStopButton.setImage(UIImage(named: "stop"), for: .normal)
    }

    func settingStopped() {
        timeText.isHidden = false
        playStopButton.isHidden = false
        trialPlusButton.isHidden = false
        trialMinusButton.isHidden = false
        framePlusButton.isHidden = false
        frameMinusButton.isHidden = false
        restartButton.isHidden = false
        playStopButton.setImage(UIImage(named: "play"), for: .normal)
    }
}

// MARK: - Extension functions
extension DisplayPreviewViewController: DisplayRenderDelegate {

    func settingTimeLabel() {
        let frame = displayRender?.timeInFrames ?? 0
        let time = Float(frame) * Flow.shared.settings.delta
        let trial = Task.shared.sectionTask.currentTrial + 1
        let totalTrials = Task.shared.sectionTask.numberOfTrials

        timeText.text = """
        trial: \(trial) of \(totalTrials)
        frame: \(frame)
        time: \(time)
        """
    }

    func showKeyboard(type: FixedKeyboard, inTitle: Bool) {}

    func addBackButton(position: FixedXButton) {
        self.controlView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: controlView.topAnchor, constant: 30).isActive = true
        button.leftAnchor.constraint(equalTo: controlView.leftAnchor, constant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 55).isActive = true
        button.heightAnchor.constraint(equalToConstant: 55).isActive = true
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    @objc func buttonAction(sender: UIButton!) {
        displayRender?.status = .stopped
        end()
    }

    func end() {
        Flow.shared.navigateBack()
    }

    func clear() {
        for i in addedViewsTag {
            if let viewWithTag = self.view.viewWithTag(i) {
                viewWithTag.removeFromSuperview()
                addedViewsTag = addedViewsTag.filter({ $0 != i })
            }
        }
        metalView.tag = Constants.metalViewTag
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

    func playVideo(video: VideoObject) {
        numberOfVideos += 1
        settingPlayingLabel()
    }

    func stopVideo() {
        numberOfVideos -= 1
        if numberOfVideos < 0 {
            numberOfVideos = 0
        }
        settingPlayingLabel()
    }

    func playAudio() {
        numberOfAudios += 1
        settingPlayingLabel()
    }

    func stopAudio() {}

    func stopOneAudio() {
        numberOfAudios -= 1
        if numberOfAudios < 0 {  // in first scene we stop a sineWave
            numberOfAudios = 0
        }
        settingPlayingLabel()
    }

    func playAudios(audio: [Float]) {
        if inactivation {
            displayRender?.status = .stopped
            inactivation = false
            settingTimeLabel()
            settingStopped()
        }
    }

    func settingKeyResponses() {}
}
