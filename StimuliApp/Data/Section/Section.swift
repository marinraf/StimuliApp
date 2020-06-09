//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Section: Codable {

    var id: String
    var name: Property
    var order: Int

    var repetitions: Property

    var trialValue: Property
    var trialValueVariable: Variable?
    var responseValue: Property
    var next: Property

    var scenes: [Scene]

    var alternate: String = ""
    var modificable: String = ""

    //empty
    init() {
        self.id = UUID().uuidString
        self.name = Property()
        self.order = 0
        self.repetitions = Property()
        self.trialValue = Property()
        self.responseValue = Property()
        self.next = Property()
        self.scenes = []
    }

    //new 
    init(name: String, order: Int) {
        self.id = UUID().uuidString
        self.name = SectionData.makeNameProperty(text: name)
        self.order = order
        self.repetitions = SectionData.makeRepetitionsProperty(float: 1)
        self.trialValue = SectionData.makeTrialValueProperty(float: 0)
        self.responseValue = SectionData.makeResponseValueProperty(selected: 0)
        self.next = SectionData.makeNextProperty()
        self.scenes = []
    }

    //copy when duplicating section
    init(from oldSection: Section, name: String, order: Int) {
        self.id = UUID().uuidString
        self.order = order
        self.name = SectionData.makeNameProperty(text: name)
        self.repetitions = Property(from: oldSection.repetitions)
        self.trialValue = Property(from: oldSection.trialValue)
        self.responseValue = Property(from: oldSection.responseValue)
        self.next = Property(from: oldSection.next)
        self.scenes = []
        self.scenes = oldSection.scenes.map({ Scene(from: $0,
                                                    sectionId: self.id,
                                                    name: $0.name.string,
                                                    order: $0.order) })

        let oldVariablesId = oldSection.scenes.flatMap({ $0.variables.map({ $0.id }) })
        let variablesId = self.scenes.flatMap({ $0.variables.map({ $0.id }) })
        let oldScenesId = oldSection.scenes.map({ $0.id })
        let scenesId = self.scenes.map({ $0.id })

        for property in [self.trialValue] + self.trialValue.properties {
            if let i = oldVariablesId.firstIndex(of: property.somethingId) {
                property.somethingId = variablesId[i]
            }
        }

        if let i = oldScenesId.firstIndex(of: responseValue.somethingId) {
            responseValue.somethingId = scenesId[i]
        }
    }

    var managedByBlocks: Bool {
        if let _ = variables.first(where: { $0.group == -1 }) {
            return true
        } else {
            return false
        }
    }

    var objects: [Object] {
        return scenes.flatMap({ $0.objects })
    }

    var variables: [Variable] {
        return objects.flatMap({ $0.variables })
    }

    var isShuffled: Bool {
        for variable in variables {
            if let selection = FixedSelection(rawValue: variable.selection.string) {
                if selection == .shuffled || selection == .random {
                    return true
                }
            }
        }
        return false
    }

    var maximumGroup: Int {
        return variables.map({ $0.group }).max() ?? 0
    }

    var differentPossibilities: Int {

        var number = 1
        var groups: [Int] = []

        for variable in self.variables {
            if variable.group == -1 {
                guard let listOfValues = variable.listOfValues else { return 0 }
                return listOfValues.numberOfTrialsIfBlock
            }
        }

        for variable in self.variables {
            guard let selection = FixedSelection(rawValue: variable.selection.string) else { return 0 }
            guard let listOfValues = variable.listOfValues else { return 0 }
            if variable.group == 0 || !groups.contains(variable.group) {
                groups.append(variable.group)
                if selection == .inOrder || selection == .shuffled {
                    for element in variable.otherVariablesInSameGroup(section: self) {
                        guard let list = element.listOfValues else { return 0 }
                        if list.values.count != listOfValues.values.count { return 0 }
                    }
                    number *= listOfValues.values.count
                } else if selection == .fixed {
                    guard let varProperty = variable.selection.properties.first(where: {
                        $0.somethingId == variable.id
                    }) else { return 0 }
                    let number = varProperty.float.toInt
                    if number > listOfValues.values.count { return 0 }
                } else if selection == .correct {
                    if let varProperty = variable.selection.properties.first(where: { $0.somethingId == variable.id}) {
                        let number = varProperty.float.toInt
                        if number > listOfValues.values.count { return 0 }
                    } else {
                        if listOfValues.values.count < 2 { return 0 }
                    }
                }
            }
        }
        return number
    }

    var error: String {

        var number = 1
        var groups: [Int] = []

        for variable in self.variables {
            guard let selection = FixedSelection(rawValue: variable.selection.string) else {
                return """
                ERROR: in variable: \(variable.name).
                """
            }
            guard let listOfValues = variable.listOfValues  else {
                return """
                ERROR: variable: \(variable.name) has no list assigned.
                """
            }
            
            if variable.group == 0 || !groups.contains(variable.group) {
                groups.append(variable.group)
                if selection == .inOrder || selection == .shuffled {
                    for element in variable.otherVariablesInSameGroup(section: self) {
                        guard let list = element.listOfValues else {
                            return """
                            ERROR: variable: \(element.name) has no list assigned.
                            """
                        }
                        if list.values.count != listOfValues.values.count {
                            return """
                            ERROR: variable: \(variable.name) and variable: \(element.name) are in the same group \
                            and they have a different number of values assigned.
                            """
                        }
                    }
                    number *= listOfValues.values.count
                } else if selection == .fixed {
                    for element in variable.otherVariablesInSameGroup(section: self) {
                        guard let varProperty = element.selection.properties.first(where: {
                            $0.somethingId == element.id
                        }) else {
                            return """
                            ERROR: in variable: \(variable.name).
                            """
                        }
                        let number = varProperty.float.toInt
                        if number > listOfValues.values.count {
                            return """
                            ERROR: variable: \(element.name) has a fixed value assigned: \(number) that is greater \
                            than its possible values: \(listOfValues.values.count).
                            """
                        }
                    }
                } else if selection == .correct {
                    for element in variable.otherVariablesInSameGroup(section: self) {
                        if let varProperty = element.selection.properties.first(where: {
                            $0.somethingId == element.id }) {
                            let number = varProperty.float.toInt
                            if number > listOfValues.values.count {
                                return """
                                ERROR: variable: \(element.name) has an initial value assigned: \(number) that is \
                                greater than its possible values: \(listOfValues.values.count).
                                """
                            }
                        } else {
                            if listOfValues.values.count < 2 {
                                return """
                                ERROR: variable: \(variable.name) needs a minimum of 2 values (one for correct and \
                                another for incorrect) an has only \(listOfValues.values.count) possible values.
                                """
                            }
                        }
                    }
                }
            }
        }
        if totalPossibilities > Constants.maxNumberOfTrials {
            return """
            ERROR: total number of trials in section: \(self.name.string) is too long.
            The maximum number of trials allowed is \(Constants.maxNumberOfTrials).
            """
        } else {
            return ""
        }
    }

    var totalPossibilities: Int {
        if managedByBlocks {
            return differentPossibilities
        } else {
            return differentPossibilities * repetitions.float.toInt
        }
    }
}
