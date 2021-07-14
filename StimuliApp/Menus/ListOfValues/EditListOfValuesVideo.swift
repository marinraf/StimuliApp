//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class EditListOfValuesVideo: Menu {

    // MARK: - Setting
    override func setting() {
        title2 = Flow.shared.listOfValues.name.string
        backButton = "< Lists of videos"

        sections = []
        makeSection0()
        makeSection1()
        makeSection2()
        makeSection3()
    }

    override func moveFunction(_ first: Int, to second: Int) {
        Flow.shared.moveValuesValues(first, to: second)
        for element in Flow.shared.listOfValues.values {
            element.float = Float(element.listOrder + 1)
        }
        Flow.shared.saveTest(Flow.shared.test)
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
        let section = MenuSection(title: "Possible values")
        section.dependency = Flow.shared.listOfValues.id
        section.collapsed = Flow.shared.test.saveSection(section)
        sections.append(section)
        for element in Flow.shared.listOfValues.values {
            makeOptionFloat(from: element, sectionNumber: sectionNumber)
        }
    }

    private func makeSection3() {
        let sectionNumber = 3
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
        var option = Option(name: "value#\((property.listOrder + 1)):   \(property.text)")
        option.style = .optional

        option.nextScreen = {

            Flow.shared.property = property

            let content = Content(title: property.nameToShow,
                                  info: option.infoMessage,
                                  type: .video,
                                  textToShow: "")

            content.saveFunction = { id, detail in

                property.text = detail
                property.somethingId = id

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
                Flow.shared.saveTest(Flow.shared.test)
                return true
            }
            return content
        }
        option.delete = {
            Flow.shared.deleteListOfValuesValue(order: property.listOrder)
            FilesAndPermission.deleteFile(fileName: property.somethingId, test: Flow.shared.test)
            return []
        }
        sections[sectionNumber].options.append(option)
    }

    private func makeNewValue(sectionNumber: Int) {
        var option = Option(name: "+ add video")
        option.style = .insert
        let info = """
        Add a new video to the list.
        The video will be imported from the media library.
        """
        option.infoMessage = info
        option.nextScreen = {
            let order = Flow.shared.listOfValues.values.count

            let property = Property(name: "",
                                    info: "",
                                    propertyType: .simpleFloat,
                                    unitType: .decimal,
                                    float: Float(order + 1))
            property.listOrder = order

            Flow.shared.property = property

            let content = Content(title: property.nameToShow,
                                  info: option.infoMessage,
                                  type: .video,
                                  textToShow: "")

            content.saveFunction = { id, detail in

                property.text = detail
                property.somethingId = id
                Flow.shared.listOfValues.values.append(property)

                for section in self.getSections() {
                    if let valueType = FixedValueType(rawValue: section.trialValue.properties[0].string) {
                        if valueType == .other {
                            let newProperty = Property(name: "",
                                                       info: "",
                                                       propertyType: .simpleFloat,
                                                       unitType: .decimal,
                                                       float: 0)

                            section.trialValue.properties[0].properties.append(newProperty)
                            SectionData.changeValueNames(property: section.trialValue.properties[0],
                                                         list: Flow.shared.listOfValues)
                        }
                    }
                }
                Flow.shared.saveTest(Flow.shared.test)
                return true
            }
            return content
        }
        sections[sectionNumber].options.append(option)
    }
}
