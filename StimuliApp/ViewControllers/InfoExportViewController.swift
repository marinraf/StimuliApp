//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import MessageUI

class InfoExportViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var groupTitleView: UIView!
    @IBOutlet weak var separatorTitleView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(_ sender: Any) {
        buttonAction()
    }

    var infoExport: InfoExport

    init() {
        self.infoExport = Flow.shared.screen as? InfoExport ?? InfoExport(type: .exportTest)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }

    private func setting() {
        infoExport.setting()

        titleLabel.text = infoExport.title
        textView.text = infoExport.info
        button.setImage(UIImage(named: infoExport.buttonImage), for: .normal)
        button.isHidden = infoExport.buttonIsHidden

        //back button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "< Back",
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

    private func buttonAction() {
        switch infoExport.type {
        case .exportTest:
            email()
        case .infoResult:
            email()
        case .previewVariables, .previewErrorStimulusOrTest:
            shuffle()
        }
    }

    private func email() {
        let message = infoExport.txt

        if MFMailComposeViewController.canSendMail() {

            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([infoExport.emailDestination])
            mail.setSubject("\(infoExport.emailTitle)")
            mail.setMessageBody(message, isHTML: true)

            for item in infoExport.emailData {
                mail.addAttachmentData(item.0, mimeType: "text/plain", fileName: item.1)
            }
            present(mail, animated: true)

        } else {
            showAlertOk(title: infoExport.alertTitle, message: infoExport.alertMessage)
        }
    }

    private func shuffle() {
        Task.shared.error = Task.shared.createSection(section: Flow.shared.section, test: Flow.shared.test)
        setting()
    }
}

extension InfoExportViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {

        controller.dismiss(animated: true)
    }
}
