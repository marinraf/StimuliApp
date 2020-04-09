//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Content: Screen {

    var style: ScreenStyle = .content
    var title: String
    var info: String
    var type: FixedMediaType
    var textToShow: String
    var id: String = ""
    var detail: String = ""
    var saveFunction: (String, String) -> (Bool) = { id, detail  in return true }

    init(title: String, info: String, type: FixedMediaType, textToShow: String) {
        self.title = title
        self.info = info
        self.type = type
        self.textToShow = textToShow
    }

    func setting() {}

    func save() -> Bool {
        return saveFunction(id, detail)
    }
}

enum FixedMediaType: String, Codable, CaseIterable {

    case image
    case text
    case video
    case audio

    var description: String {
        return self.rawValue
    }

    var name: String {
        return self.rawValue
    }
}
