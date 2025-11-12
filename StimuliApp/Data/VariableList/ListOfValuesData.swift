//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

struct ListOfValuesData {

    static func makeNameProperty(text: String, dimensions: Int) -> Property {

        let property = Property(name: "name",
                                info: "A name to identify this list.",
                                text: text)
        if dimensions > 3 {
            property.onlyInfo = true
        }
        return property
    }

    static func makeJitteringValueProperty(float: Float) -> Property {
        return Property(name: "jitteringValue",
                        info: """
                        If the jittering is not zero, a numeric value in the range (-jitteringValue, jitteringValue) \
                        is randomly generated for each trial and added to the corresponding value from the list.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .decimal,
                        float: float)
    }

    static func makeValuesOrderProperty(selected: Int) -> Property {
        return Property(name: "shuffled",
                        info: """
                        Whether the values in the list are always in the same order or if they are shuffled every \
                        time the test is run.
                        """,
                        propertyType: .listOrder,
                        unitType: .decimal,
                        fixedValues: FixedListOrder.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeNumberOfBlocksProperty(float: Float) -> Property {
        return Property(name: "numberOfBlocks",
                        info: """
                        The number of blocks.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeLengthOfBlocksProperty(float: Float) -> Property {
        return Property(name: "lengthOfBlocks",
                        info: """
                        The length of the blocks (the number of trials for each block).
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveDecimalWithoutZero,
                        float: float)
    }

    static func makeTypesOfBlocksProperty(selected: Int) -> Property {
        return Property(name: "typesOfBlocks",
                        info: """
                        All blocks can be of the same type, or there can be 2 different types of blocks.
                        """,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedListBlockType.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeFirstListProperty(float: Float) -> Property {

        return Property(name: "firstList",
                        info: """
                        The first list for the block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeSecondListProperty(float: Float) -> Property {

        return Property(name: "secondList",
                        info: """
                        The second list for the block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeStartingListProperty(selected: Int) -> Property {

        return Property(name: "startingList",
                        info: """
                        The starting list for the block.
                        """,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedListStarting.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeProbChangeListProperty(float: Float) -> Property {

        return Property(name: "probChangeList",
                        info: """
                        The probability of changing the list when a trial finishes.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .valueFrom0to1,
                        float: float)
    }

    static func makeStartingBlockProperty(selected: Int) -> Property {

        return Property(name: "startingBlock",
                        info: """
                        The starting block of the test.
                        """,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedListStarting.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeProbChangeBlockProperty(float: Float) -> Property {

        return Property(name: "probChangeBlock",
                        info: """
                        The probability of changing the type of block when a block finishes.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .valueFrom0to1,
                        float: float)
    }

    static func makeFirstBlockFirstListProperty(float: Float) -> Property {

        return Property(name: "firstBlockFirstList",
                        info: """
                        The first list for the first block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeFirstBlockSecondListProperty(float: Float) -> Property {

        return Property(name: "firstBlockSecondList",
                        info: """
                        The second list for the first block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeFirstBlockStartingListProperty(selected: Int) -> Property {

        return Property(name: "firstBlockStartingList",
                        info: """
                        The starting list for the first block.
                        """,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedListStarting.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeFirstBlockProbChangeListProperty(float: Float) -> Property {

        return Property(name: "firstBlockProbChangeList",
                        info: """
                        The probability of changing the list when a trial of the first block finishes.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .valueFrom0to1,
                        float: float)
    }

    static func makeSecondBlockFirstListProperty(float: Float) -> Property {

        return Property(name: "secondBlockFirstList",
                        info: """
                        The first list for the second block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeSecondBlockSecondListProperty(float: Float) -> Property {

        return Property(name: "secondBlockSecondList",
                        info: """
                        The second list for the second block.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .positiveIntegerWithoutZero,
                        float: float)
    }

    static func makeSecondBlockStartingListProperty(selected: Int) -> Property {

        return Property(name: "secondBlockStartingList",
                        info: """
                        The starting list for the second block.
                        """,
                        propertyType: .select,
                        unitType: .decimal,
                        fixedValues: FixedListStarting.allCases.map({ $0.name }),
                        selectedValue: selected)
    }

    static func makeSecondBlockProbChangeListProperty(float: Float) -> Property {

        return Property(name: "secondBlockProbChangeList",
                        info: """
                        The probability of changing the list when a trial of the second block finishes.
                        """,
                        propertyType: .simpleFloat,
                        unitType: .valueFrom0to1,
                        float: float)
    }
}

//do not change the names without checking the comment fixedNames
enum FixedListOrder: String, Codable, CaseIterable {

    case inOrder = "in order"
    case shuffled = "shuffled"

    var description: String {
        switch self {
        case .inOrder:
            return """
            The values in the list are always in the same order. \
            When an object selects values from the list, it can select the values in order or randomly, \
            but the list itself is always in the same order.
            """
        case .shuffled:
            return """
            The values in the list are shuffled once at the beginning of each test.
            """
        }
    }

    var name: String {
        return self.rawValue
    }
}

//do not change the names without checking the comment fixedNames
enum FixedListBlockType: String, Codable, CaseIterable {

    case one = "1"
    case two = "2"

    var name: String {
        return self.rawValue
    }
}

//do not change the names without checking the comment fixedNames
enum FixedListStarting: String, Codable, CaseIterable {

    case random = "random"
    case first = "first"
    case second = "second"

    var name: String {
        return self.rawValue
    }
}
