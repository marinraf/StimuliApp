//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class InfoExport: Screen {

    enum InfoType {
        case exportTest
        case previewVariables
        case previewErrorStimulusOrTest
        case infoResult
    }

    var style: ScreenStyle = .infoExport
    var type: InfoType
    var title: String = ""
    var info: String = ""

    var emailDestination: String = Flow.shared.settings.emailProperty.string
    var emailTitle: String = ""
    var txt: String = ""
    var emailData: [(Data, String)] = []

    var alertTitle: String = "Error"
    var alertMessage: String = "Error sending the email"

    var buttonImage: String = ""
    var buttonIsHidden: Bool = false

    init(type: InfoType) {
        self.type = type
        switch type {
        case .previewErrorStimulusOrTest:
            self.buttonIsHidden = true
        case .exportTest, .infoResult, .previewVariables:
            self.buttonIsHidden = false
        }
    }

    func setting() {
        switch type {
        case .exportTest:
            title = "Export test: \(Flow.shared.test.name.string) to a file"
            info = Texts.export
            buttonImage = "email"

            emailTitle = Flow.shared.test.name.string
            txt = "User: \(Flow.shared.settings.userProperty.string)<br />Test: \(Flow.shared.test.name.string)<br />"
            if let testData = Encode.testToJsonData(test: Flow.shared.test) {
                emailData = [(testData, emailTitle + ".stimulitest")]
            }


        case .previewVariables:
            title = Task.shared.sectionTask.name + " info"
            info = Task.shared.sectionTask.info
            buttonImage = "shuffle"

        case .previewErrorStimulusOrTest:
            title = "Error"
            info = Task.shared.sectionTask.info

        case .infoResult:
            self.title = Flow.shared.result.name.string
            self.info = Flow.shared.result.data
            buttonImage = "email"

            emailTitle = Flow.shared.result.name.string + " " + Flow.shared.result.dateString
            txt = "User: \(Flow.shared.settings.userProperty.string)"
            txt += "<br />Result from test: \(Flow.shared.result.name.string)"
            txt += "<br />Date: \(Flow.shared.result.dateString)<br />"

            if let resultData = info.data(using: .utf8) {
                emailData = [(resultData, emailTitle + ".txt")]
            }

            for (index, csv) in Flow.shared.result.csvs.enumerated() where csv != "" {
                let newName = Flow.shared.result.csvNames[index]
                if let sessionData = csv.data(using: .utf8) {
                    emailData.append((sessionData, emailTitle + " " + newName + ".csv"))
                }
            }
        }
    }
}
