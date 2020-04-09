//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct ResultData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: Texts.resultName,
                        text: text)
    }
}
