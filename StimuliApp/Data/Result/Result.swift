//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Result: NSObject, Codable {

    var id: String
    var name: Property
    var order: Int
    var data: String
    var date: Date
    var csvs: [String]
    var csvNames: [String]
    var sent: Bool
    var responseKeyboard: String

    override init() {
        id = UUID().uuidString
        name = Property()
        order = 0
        data = ""
        date = Date()
        csvs = []
        csvNames = []
        sent = false
        responseKeyboard = ""
    }

    //new result
    init(name: String, order: Int) {
        self.id = UUID().uuidString
        self.order = order

        self.name = ResultData.makeNameProperty(text: name)
        self.data = ""
        self.date = Date()
        self.csvs = []
        self.csvNames = []
        self.sent = false
        self.responseKeyboard = ""
    }

    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    var dateStringForFile: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd--HH-mm-ss"
        return dateFormatter.string(from: date)
    }
}
