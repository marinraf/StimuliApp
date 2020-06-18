//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class Menu: Screen {

    class MenuSection {
        var title: String
        var options: [Option] = []
        var collapsed: Bool = false
        var dependency: String = ""

        var numberOfRows: Int {
            return options.count
        }

        var names: [String] {
            return options.map({ $0.name })
        }

        var reference: String {
            return dependency + title
        }

        init(title: String) {
            self.title = title
        }

        func toggleCollapse() {
            Flow.shared.test.toogleSection(self)
            collapsed.toggle()
        }
    }

    struct Option {

        enum Style {
            case insert
            case runTest
            case optional
            case optionalInfo
            case standard
            case onlyInfo
            case onlySelect
            case selectFromSegment
            case highlight
        }

        var name: String
        var detail: String = ""
        var infoTitle: String
        var infoMessage: String = ""
        var style: Style = .standard
        var color: Color = .defaultCell
        var nextScreen: () -> Screen? = { return nil }
        var delete: () -> [IndexPath] = { return [] }
        var segments: [Segment] = []
        var selectedSegment: Int = 0
        var position: Int = 0
        var deleteTexts: (title: String, message: String) = ("", "")
        var canDuplicate: Bool = false
        var duplicate: () -> [IndexPath] = { return [] }

        init(name: String) {
            self.name = name
            self.infoTitle = name
        }
    }

    struct Segment {
        var title: String
        var action: () -> () = {}

        init(title: String) {
            self.title = title
        }
    }

    var style: ScreenStyle
    var title: String
    var title2: String = ""
    var backButton: String = ""
    var buttonImage: String = ""
    var export: Bool = false
    var sections: [MenuSection] = []
    var secondMoveSection: Int = 10000

    init(title: String, style: ScreenStyle = .menu) {
        self.title = title
        self.style = style
    }

    func setting() { }

    var previewButtonHidden: Bool {
        return buttonImage == "" ? true : false
    }

    var numberOfSections: Int {
        return sections.count
    }

    var isEditable: Bool {
        for section in sections {
            for option in section.options where option.style == .optional || option.style == .optionalInfo {
                return true
            }
        }
        return export
    }

    func numberOfRows(inSection section: Int) -> Int {
        return sections[section].numberOfRows
    }

    func option(at indexPath: IndexPath) -> Option {
        return sections[indexPath.section].options[indexPath.row]
    }

    func title(forSection section: Int) -> String {
        if sections.count > section {
            return sections[section].title
        } else {
            return ""
        }
    }

    //functions to delete, insert, move or save data
    func deleteOption(at indexPath: IndexPath) -> [IndexPath] {
        let optionToDelete = option(at: indexPath)
        let rowsToDeleteOrInsert = optionToDelete.delete()
        setting()
        return rowsToDeleteOrInsert
    }

    func duplicateOption(at indexPath: IndexPath) -> [IndexPath] {
        let optionToDuplicate = option(at: indexPath)
        let rowsToDeleteOrInsert = optionToDuplicate.duplicate()
        setting()
        return rowsToDeleteOrInsert
    }

    func move(_ first: Int, to second: Int) {
        moveFunction(first, to: second)
        setting()
    }

    func move2(_ first: Int, to second: Int) {
        moveFunction2(first, to: second)
        setting()
    }

    //customizable function for menu screen
    func moveFunction(_ first: Int, to second: Int) { }
    func moveFunction2(_ first: Int, to second: Int) { }

    // MARK: - Create Options
    func makeOption(from property: Property, sectionNumber: Int,
                    badNames: [String] = [], position: Int = 0, defaultSettings: Bool = false) {

        if property.onlyInfo {
            makeOptionInfo(from: property, sectionNumber: sectionNumber, position: position)
        } else {
            switch property.propertyType {
            case .font:
                makeOptionFont(from: property, sectionNumber: sectionNumber, position: position)
            case .string:
                makeOptionString(from: property, sectionNumber: sectionNumber,
                                 badNames: badNames, position: position, defaultSettings: defaultSettings)
            case .key:
                makeOptionKey(from: property, sectionNumber: sectionNumber,
                              badNames: badNames, position: position, defaultSettings: defaultSettings)
            case .select, .size2d, .origin2d, .originResponse, .position2d, .positionResponse, .color,
                 .behaviour, .direction, .soundType, .shape, .border, .noise, .contrast, .modulator, .sceneDuration,
                 .objectResponse, .keyResponse, .gamma, .randomness, .listOrder, .selection,
                 .selectionDifferent, .selectionOrder, .valueType, .correctType, .distance:
                makeOptionSelect(from: property, sectionNumber: sectionNumber, position: position)
                for element in property.properties {
                    makeOption(from: element, sectionNumber: sectionNumber,
                               position: position + 1)
                }
            case .timeFloat, .response, .value, .correct:
                makeOptionFloat(from: property, sectionNumber: sectionNumber,
                                position: position, defaultSettings: defaultSettings)
                for element in property.properties {
                    makeOption(from: element, sectionNumber: sectionNumber,
                               position: position + 1)
                }
            case .type:
                makeOptionFloat(from: property, sectionNumber: sectionNumber,
                                position: position, defaultSettings: defaultSettings, style: .highlight)
                for element in property.properties {
                    makeOption(from: element, sectionNumber: sectionNumber,
                               position: position + 1)
                }
            case .simpleFloat, .simpleFloatText, .doblePosition, .dobleSize, .triple, .sequence, .finalFloat,
                 .image, .text, .video, .audio:
                makeOptionFloat(from: property, sectionNumber: sectionNumber,
                                position: position, defaultSettings: defaultSettings)
            }
        }
    }

    func makeOptionFont(from property: Property, sectionNumber: Int, position: Int) {

        var option = Option(name: property.nameToShow + ":")
        option.detail = property.string
        option.infoMessage = property.info
        option.position = position

        option.nextScreen = {
            var textToShow = ""
            if let index = Flow.shared.test.allProperties.firstIndex(where: { $0 === property }) {
                if index > 0 {
                    textToShow = Flow.shared.test.allProperties[index - 1].descriptiveString
                }
            }
            Flow.shared.property = property
            let content = Content(title: property.nameToShow,
                                  info: option.infoMessage,
                                  type: .text,
                                  textToShow: textToShow)
            return content
        }
        sections[sectionNumber].options.append(option)
    }

    func makeOptionString(from property: Property, sectionNumber: Int,
                          badNames: [String], position: Int, defaultSettings: Bool) {
        var option = Option(name: property.nameToShow + ":")
        option.detail = property.string
        option.infoMessage = property.info
        option.position = position

        option.nextScreen = {
            let modify = Modify(title: property.nameToShow,
                                info: option.infoMessage,
                                badNames: badNames,
                                property: property)
            modify.saveFunctionString = { response in
                property.text = response
                if defaultSettings {
                    UserDefaults.standard.set(response, forKey: property.nameToShow)
                    UserDefaults.standard.set(true, forKey: property.nameToShow + "Saved")
                    Flow.shared.settings.updateProperties()
                } else {
                    Flow.shared.saveTest(Flow.shared.test)
                }
                return .saved
            }
            return modify
        }
        sections[sectionNumber].options.append(option)
    }

    func makeOptionKey(from property: Property, sectionNumber: Int,
                          badNames: [String], position: Int, defaultSettings: Bool) {
        var option = Option(name: property.nameToShow + ":")
        option.detail = property.string
        option.infoMessage = property.info
        option.position = position

        option.nextScreen = {
            let modify = Modify(title: property.nameToShow,
                                info: option.infoMessage,
                                badNames: badNames,
                                property: property)
            modify.saveFunctionString = { response in
                property.text = response.prefix(1).uppercased()
                Flow.shared.saveTest(Flow.shared.test)
                return .saved
            }
            return modify
        }
        sections[sectionNumber].options.append(option)
    }

    func makeOptionInfo(from property: Property, sectionNumber: Int, position: Int) {
        var option = Option(name: property.nameToShow + ":")
        option.detail = property.string
        option.infoMessage = property.info
        option.style = .onlyInfo
        option.position = position
        sections[sectionNumber].options.append(option)
    }

    func makeOptionFloat(from property: Property, sectionNumber: Int,
                         position: Int, defaultSettings: Bool, style: Option.Style = .standard) {
        var option = Option(name: property.nameToShow + ":")
        option.detail = property.string
        option.style = style
        option.infoMessage = property.info
        if property.timeDependency == .timeDependent {
            option.infoMessage += "\n\n" + property.timeFunction.description
        }
        option.position = position

        option.nextScreen = {
            let modify = Modify(title: property.nameToShow,
                                info: property.info,
                                property: property)
            modify.saveFunctionFloats = { response in
                let oldValue = property.float
                property.changeValue(new: response)
                if property.unitType == .externalSize {
                    Flow.shared.test.changeAllVisualDegrees(newDistanceCm: property.float, oldDistanceCm: oldValue)
                }
                if defaultSettings {
                    UserDefaults.standard.set(property.float, forKey: property.nameToShow)
                    UserDefaults.standard.set(property.float1, forKey: property.nameToShow + "1")
                    UserDefaults.standard.set(true, forKey: property.nameToShow + "Saved")
                    Flow.shared.settings.updateProperties()
                } else if let newVariable = property.variable {
                    for newSelection in Flow.shared.section.variables.map({ $0.selection }) {
                        for newProperty in newSelection.properties {
                            if newProperty.variable === newVariable {
                                newProperty.changeValue(new: response)
                            }
                        }
                    }
                    Flow.shared.saveTest(Flow.shared.test)
                } else {
                    Flow.shared.saveTest(Flow.shared.test)
                }
                return .saved
            }
            modify.saveFunctionSelect = {
                Flow.shared.saveTest(Flow.shared.test)
                return .saved
            }
            modify.saveFunctionString = { _ in
                property.addProperties()
                Flow.shared.saveTest(Flow.shared.test)
                return .saved
            }
            return modify
        }
        sections[sectionNumber].options.append(option)
    }

    func makeOptionSelect(from property: Property, sectionNumber: Int, position: Int) {
        var option = Option(name: property.nameToShow + ":")
        option.infoMessage = property.info
        let fixed = property.propertyType.fixedValuesInfo
        if !fixed.isEmpty {
            for (index, element) in property.propertyType.fixedValues.enumerated() {
                option.infoMessage += "\n\n" + element + ": " + property.propertyType.fixedValuesInfo[index]
            }
        }
        option.style = .selectFromSegment
        option.position = position

        for (index, element) in property.fixedValues.enumerated() {
            var segment = Segment(title: element)
            segment.action = {
                property.changeSelectedValue(new: index, propertyType: property.propertyType)
                Flow.shared.saveTest(Flow.shared.test)
            }
            option.segments.append(segment)
        }
        option.selectedSegment = property.selectedValue

        sections[sectionNumber].options.append(option)
    }
}
