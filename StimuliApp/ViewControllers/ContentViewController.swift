//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import Photos
import MobileCoreServices
import MediaPlayer

class ContentViewController: UIViewController {

    var names: [String] = []
    var selectedRow: Int = 0
    var finished: Bool = false

    @IBOutlet weak var groupTitleView: UIView!
    @IBOutlet weak var separatorTitleView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBAction func okButtonPressed(_ sender: Any) {
        save()
        Flow.shared.navigateBack()
    }
    @IBOutlet weak var textInfo: UILabel!
    @IBOutlet weak var picker: UIPickerView!

    var content: Content

    init() {
        self.content = Flow.shared.screen as? Content ?? Content(title: "", info: "", type: .image, textToShow: "")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.background.toUIColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        groupTitleView.backgroundColor = Color.navigation.toUIColor
        separatorTitleView.backgroundColor = Color.separatorArrow.toUIColor
        setting()
        self.tabBarController?.tabBar.isHidden = true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    func save() {
        switch content.type {
        case .image, .video, .audio:
            _ = content.save()
        case .text:
            Flow.shared.property.text = names[selectedRow]
            Flow.shared.saveTest(Flow.shared.test)
        }
    }

    // MARK: - Setting
    func setting() {
        okButton.isHidden = true
        picker.isHidden = true
        textInfo.isHidden = true
        if !finished {
            switch content.type {
            case .image:
                separatorTitleView.isHidden = true
                settingImage()
            case .text:
                separatorTitleView.isHidden = false
                okButton.isHidden = false
                picker.isHidden = false
                textInfo.isHidden = false
                settingBackButton()
                settingFont()
            case .video:
                separatorTitleView.isHidden = true
                settingVideo()
            case .audio:
                separatorTitleView.isHidden = true
                settingAudio()
            }
        }

        //back button
        self.navigationItem.hidesBackButton = true
    }

    private func settingBackButton() {
        let newBackButton = UIBarButtonItem(title: "< Cancel",
                                            style: .done,
                                            target: self,
                                            action: #selector(goBack))
        newBackButton.tintColor = Color.selection.toUIColor
        newBackButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)
            ], for: .normal)
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc private func goBack() {
        Flow.shared.navigateBack()
    }

    private func settingFont() {
        for familyName in UIFont.familyNames {
            names += UIFont.fontNames(forFamilyName: familyName)
        }

        let number = names.firstIndex(of: Flow.shared.property.text) ?? 0
        picker.selectRow(number, inComponent: 0, animated: false)
        textInfo.adjustsFontSizeToFitWidth = true
        textInfo.text = content.textToShow
        textInfo.font = UIFont(name: Flow.shared.property.somethingId, size: 20)
    }
}

// MARK: - Picker functions
extension ContentViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return names.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return names[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textInfo.font = UIFont(name: names[row], size: 20)
        selectedRow = row
    }
}

extension ContentViewController: MPMediaPickerControllerDelegate {
    func settingAudio() {
        if checkPermissionForMediaLibrary() {
            let picker = MPMediaPickerController(mediaTypes: .anyAudio)
            picker.delegate = self
            present(picker, animated: true)
        }
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        finished = true
        dismiss(animated: true)
        Flow.shared.navigateBack()
    }

    @objc public func mediaPicker(_ mediaPicker: MPMediaPickerController,
                                  didPickMediaItems mediaItemCollection: MPMediaItemCollection) {

        if let audioURL = mediaItemCollection.items[0].value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
            let name = FilesAndPermission.saveAudio(audioURL: audioURL, test: Flow.shared.test)
            let asset = AVAsset(url: audioURL)
            var fileName = "unknown"
            if let file = mediaItemCollection.items[0].title {
                let ext = audioURL.pathExtension
                fileName = "\(file).\(ext)"
            }
            let duration = asset.duration
            let durationTime = Float(CMTimeGetSeconds(duration))
            let durationString = "\(fileName) : \(durationTime) seconds"

            FilesAndPermission.deleteFile(fileName: Flow.shared.property.somethingId, test: Flow.shared.test)

            content.id = name
            content.detail = durationString
            finished = true
            save()
        }
        finished = true
        dismiss(animated: true)
        Flow.shared.navigateBack()
    }
}

extension ContentViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func settingImage() {
        if checkPermissionForPhotoLibrary() {
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.delegate = self
            picker.modalPresentationStyle = .overCurrentContext
            picker.navigationBar.barTintColor = Color.navigation.toUIColor
            picker.navigationBar.tintColor = Color.selection.toUIColor
            present(picker, animated: true)
        }
    }

    func settingVideo() {
        if checkPermissionForPhotoLibrary() {
            let picker = UIImagePickerController()
            picker.allowsEditing = false
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.delegate = self
            picker.modalPresentationStyle = .overCurrentContext
            picker.navigationBar.barTintColor = Color.navigation.toUIColor
            picker.navigationBar.tintColor = Color.selection.toUIColor
            present(picker, animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finished = true
        dismiss(animated: true)
        Flow.shared.navigateBack()
    }

    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if content.type == .image {
            if let newImage = info[.originalImage] as? UIImage {
                let width = Int(round(newImage.size.width))
                let height = Int(round(newImage.size.height))
                let size = "\(width) x \(height) pixels"
                let name = FilesAndPermission.saveImage(image: newImage)

                FilesAndPermission.deleteFile(fileName: Flow.shared.property.somethingId, test: Flow.shared.test)

                content.id = name
                content.detail = size
                finished = true
                save()
            }
        } else if content.type == .video {
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                let name = FilesAndPermission.saveVideo(videoURL: videoURL)
                let asset = AVAsset(url: videoURL)
                let duration = asset.duration
                let durationTime = Float(CMTimeGetSeconds(duration))
                let durationString = "\(durationTime) seconds"

                FilesAndPermission.deleteFile(fileName: Flow.shared.property.somethingId, test: Flow.shared.test)

                content.id = name
                content.detail = durationString
                finished = true
                save()
            }
        }
        finished = true
        dismiss(animated: true)
        Flow.shared.navigateBack()
    }
}

// MARK: - Show Alerts and Permissions
extension ContentViewController {
    fileprivate func checkPermissionForMediaLibrary() -> Bool {
        let authStatus = MPMediaLibrary.authorizationStatus()
        switch authStatus {
        case .denied:
            showAlertPermissions()
            return false
        default:
            return true
        }
    }

    fileprivate func checkPermissionForPhotoLibrary() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .denied:
            showAlertPermissions()
            return false
        default:
            return true
        }
    }
}
