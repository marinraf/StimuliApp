//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct ObjectData {

    static func makeNameProperty(text: String) -> Property {

        return Property(name: "name",
                        info: "A name to identify this object.",
                        text: text)
    }

    static func makeStimulusProperty(text: String) -> Property {

        let property = Property(name: "stimulus",
                                info: "Stimulus name.",
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeTypeProperty(text: String) -> Property {

        let property = Property(name: "type",
                                info: "Stimulus type.",
                                text: text)

        property.onlyInfo = true
        return property
    }

    static func makeShapeProperty(text: String) -> Property {

        let property =  Property(name: "shape",
                                 info: "Stimulus shape.",
                                 text: text)

        property.onlyInfo = true
        return property
    }
}
