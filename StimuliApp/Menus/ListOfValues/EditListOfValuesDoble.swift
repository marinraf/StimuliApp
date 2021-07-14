//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditListOfValuesDoble: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.listOfValues.name.string
        backButton = "< Lists"

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
        makeSection3()
        makeSection4()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveValuesValues(first, to: second)
    }

    // MARK: - Sections
    private func makeSection0() {
        let sectionNumber = 0
        let section = MenuSection(title: "List name")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.name,
                   sectionNumber: sectionNumber,
                   badNames: Flow.shared.test.listsOfValues.map({ $0.name.string }))
    }

    private func makeSection1() {
        let sectionNumber = 1
        let section = MenuSection(title: "Order of the values")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.valuesOrder, sectionNumber: sectionNumber)
    }

    private func makeSection2() {
        let sectionNumber = 2
        let section = MenuSection(title: "Jittering of the values")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        makeOption(from: Flow.shared.listOfValues.jittering, sectionNumber: sectionNumber)
    }

    private func makeSection3() {
        let sectionNumber = 3
        let section = MenuSection(title: "Possible values")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        for element in Flow.shared.listOfValues.values {
            makeOptionFloat(from: element, sectionNumber: sectionNumber)
        }
    }

    private func makeSection4() {
        let sectionNumber = 4
        let section = MenuSection(title: "")
        section.collapsed = sections[sectionNumber - 1].collapsed
        sections.append(section)
        makeNewValue(sectionNumber: sectionNumber)
    }

    // MARK: - Options
    private func getSections() -> [Section] {
        var result: [Section] = []
        for variable in Flow.shared.test.allVariables where variable.listOfValuesId == Flow.shared.listOfValues.id {
            for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {
                result.append(section)
            }
        }
        return result
    }

    private func makeOptionFloat(from property: Property, sectionNumber: Int) {
        var option = Option(name: "value#\((property.listOrder + 1)):   \(property.string)")
        option.style = .optional
        option.canDuplicate = true

        option.nextScreen = {

            var keys: [String] = []

            if let vari = Flow.shared.test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
                if let values = vari.listOfValues?.allValuesBlock {
                    keys = values.map({ $0.id })
                }
            }
            
            let modify = Modify(title: "value",
                                info: "",
                                property: property)

            modify.saveFunctionFloats = { response in
                property.changeValue(new: response)
                for variable in Flow.shared.test.allVariables
                    where variable.listOfValuesId == Flow.shared.listOfValues.id {
                        for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {
                            SectionData.changeValueNames(property: section.trialValue.properties[0],
                                                         list: Flow.shared.listOfValues)
                        }
                }

                for section in self.getSections() {
                    SectionData.changeValueNames(property: section.trialValue.properties[0],
                                                 list: Flow.shared.listOfValues)
                }

                if let vari = Flow.shared.test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
                    for section in Flow.shared.test.sections where section.trialValue.somethingId == vari.id {
                        SectionData.addPropertiesToValueTypeWithDict(property: section.trialValue.properties[0],
                                                                     oldKeys: keys)
                    }
                }
                
                Flow.shared.saveTest(Flow.shared.test)
                return .saved
            }
            return modify
        }
        option.delete = {
            Flow.shared.deleteListOfValuesValue(order: property.listOrder)
            return []
        }
        option.duplicate = {
            let newProperty = Property(from: property)
            let first = property.listOrder
            let second = Flow.shared.listOfValues.values.count
            newProperty.listOrder = second
            Flow.shared.listOfValues.values.append(newProperty)
            for section in self.getSections() {
                if let valueType = FixedValueType(rawValue: section.trialValue.properties[0].string) {
                    if valueType == .other {
                        let newProperty = Property(name: "",
                                                   info: "",
                                                   propertyType: .simpleFloat,
                                                   unitType: .responseUnit,
                                                   float: 0)
                        section.trialValue.properties[0].properties.append(newProperty)
                        SectionData.changeValueNames(property: section.trialValue.properties[0],
                                                     list: Flow.shared.listOfValues)
                    }
                }
            }
            Flow.shared.moveValuesValues(second, to: first + 1)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValue(sectionNumber: Int) {
        var option = Option(name: "+ add vector")
        option.style = .insert
        option.infoMessage = "Add a new 2d vector to the list."
        option.nextScreen = {

            var keys: [String] = []

            if let vari = Flow.shared.test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
                if let values = vari.listOfValues?.allValuesBlock {
                    keys = values.map({ $0.id })
                }
            }
            
            let property = Property(name: "value",
                                    info: "",
                                    propertyType: .doblePosition,
                                    unitType: .variableUnit,
                                    float: 0)
            property.timeDependency = .alwaysConstant
            property.listOrder = Flow.shared.listOfValues.values.count

            let modify = Modify(title: "value",
                                info: "Horizontal value - Vertical value",
                                property: property)

            modify.saveFunctionFloats = { response in
                property.changeValue(new: response)
                Flow.shared.listOfValues.values.append(property)
                for section in self.getSections() {
                    if let valueType = FixedValueType(rawValue: section.trialValue.properties[0].string) {
                        if valueType == .other {
                            let newProperty = Property(name: "",
                                                       info: "",
                                                       propertyType: .simpleFloat,
                                                       unitType: .responseUnit,
                                                       float: 0)
                            section.trialValue.properties[0].properties.append(newProperty)
                            SectionData.changeValueNames(property: section.trialValue.properties[0],
                                                         list: Flow.shared.listOfValues)
                        }
                    }
                }

                if let vari = Flow.shared.test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
                    for section in Flow.shared.test.sections where section.trialValue.somethingId == vari.id {
                        SectionData.addPropertiesToValueTypeWithDict(property: section.trialValue.properties[0],
                                                                     oldKeys: keys)
                    }
                }

                Flow.shared.saveTest(Flow.shared.test)
                return .saved
            }
            return modify
        }
        sections[sectionNumber].options.append(option)
    }
}
