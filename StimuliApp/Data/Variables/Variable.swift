//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Variable: Codable {

    var id: String

    var objectId: String
    var propertyId: String
    var listOfValuesId: String
    var group: Int
    var selection: Property

    //empty
    init() {
        self.id = UUID().uuidString

        self.objectId = ""
        self.propertyId = ""
        self.listOfValuesId = ""
        self.group = 0
        self.selection = Property()
    }

    //new
    init(objectId: String, propertyId: String) {
        self.id = UUID().uuidString

        self.objectId = objectId
        self.propertyId = propertyId
        self.listOfValuesId = ""
        self.group = 0
        self.selection = VariableData.makeSelectionProperty(selected: 0)
    }

    //copy when duplicating scene or section
    init(from oldVariable: Variable, object: Object) {
        self.id = UUID().uuidString

        self.objectId = object.id
        self.propertyId = oldVariable.propertyId
        self.listOfValuesId = oldVariable.listOfValuesId
        self.group = oldVariable.group
        self.selection = Property(from: oldVariable.selection)
    }

    var object: Object? {
        return Flow.shared.test.objects.first(where: { $0.id == objectId })
    }

    var property: Property? {
        return Flow.shared.test.allProperties.first(where: { $0.id == propertyId })
    }

    var listOfValues: ListOfValues? {
        return Flow.shared.test.listsOfValues.first(where: { $0.id == listOfValuesId })
    }

    var dimensions: Int {
        return property?.dimensions ?? 1
    }

    var scene: Scene? {
        return object?.scene
    }

    var section: Section? {
        return scene?.section
    }

    var stimulus: Stimulus? {
        return object?.stimulus
    }

    var realName: String {
        let sceneName = scene?.name.string ?? ""
        let objectName = object?.name.string ?? ""
        let propertyName = property?.name ?? ""
        return sceneName + objectName.prependingSymbol() + propertyName.prependingSymbol()
    }

    var name: String {
        var name0 = realName
        if name0 == "__trialValue" {
            if let list = listOfValues {
                name0 = "_list_\(list.name.string)"
            }
        }
        return name0
    }

    var inGroup: Bool {
        if group == 0 || group == -1 {
            return false
        } else {
            return true
        }
    }

    func allVariablesInSameGroup(section: Section) -> [Variable] {
        if self.inGroup {
            return section.allVariables.filter({ $0.group == self.group })
        } else {
            return [self]
        }
    }

    func otherVariablesInSameGroup(section: Section) -> [Variable] {
        return allVariablesInSameGroup(section: section).filter({ $0 !== self })
    }
}
