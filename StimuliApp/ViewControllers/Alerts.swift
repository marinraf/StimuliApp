//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit

extension UIViewController {
    func showAlertOk(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertTestIsFinished(action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.testFinished,
                                      message: Texts.thanks,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: action))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertTestIsFinishedPreview(action: @escaping (UIAlertAction) -> Void,
                                        action2: @escaping (UIAlertAction) -> Void) {
        let message0 = Texts.longFrames

        let message = message0 + "\n\n" + Flow.shared.frameControl.longFramesString

        let alert = UIAlertController(title: Texts.testFinished,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: action))
        alert.addAction(UIAlertAction(title: "More Info", style: UIAlertAction.Style.default, handler: action2))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertFirstMessageTest(resume: @escaping (UIAlertAction) -> Void, end: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.testStarted,
                                      message: Texts.firstMessageTest,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertFirstMessageMac(resume: @escaping (UIAlertAction) -> Void, end: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.testStarted,
                                      message: "",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertNeedToSync(resume: @escaping (UIAlertAction) -> Void, end: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Re-sync",
                                      message: Texts.needToSync,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAlertFixationBroken(resume: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.fixation,
                                      message: Texts.fixationBroken,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAlertDistanceBrokenFar(resume: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.distance,
                                      message: Texts.distanceBrokenFar,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAlertDistanceBrokenClose(resume: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.distance,
                                      message: Texts.distanceBrokenClose,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertDistanceBrokenNan(resume: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.distance,
                                      message: Texts.distanceBrokenNan,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: resume))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertCancelTest(resume: @escaping (UIAlertAction) -> Void, end: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.testEnd,
                                      message: Texts.testEnd2,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Texts.testContinue, style: UIAlertAction.Style.default, handler: resume))
        alert.addAction(UIAlertAction(title: Texts.testEnd, style: UIAlertAction.Style.default, handler: end))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertDelete(title: String, message: String, action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: action))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertDuplicate(action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "Duplicate",
                                      message: "Do you want to duplicate this element?",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Duplicate", style: UIAlertAction.Style.default, handler: action))
        self.present(alert, animated: false, completion: nil)
    }

    func showAlertPermissions() {
        let alert = UIAlertController(title: "Error",
                                      message: "Permissions are needed to access.",
                                      preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { (_) -> Void in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: [:],
                                      completionHandler: nil)
        })
        present(alert, animated: false)
    }

    func showAlertDRM() {
        let alert = UIAlertController(title: "Error",
                                      message: "Unable to read DRM protected file.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAlertCalibration(action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.calibrationTitle,
                                      message: Texts.calibration,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: action))
        self.present(alert, animated: false, completion: nil)
    }
    
    func showAlertCalibrationError(action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: Texts.calibrationTitle,
                                      message: Texts.calibrationError,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: action))
        self.present(alert, animated: false, completion: nil)
    }

}
