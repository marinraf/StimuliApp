//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

class ListOfValues: Codable {

    enum ListType: String, Codable, CaseIterable {
        case values
        case vectors
        case colors
        case images
        case texts
        case videos
        case audios
        case blocks

        var dimensions: Int {
            switch self {
            case .values:
                return 1
            case .vectors:
                return 2
            case .colors:
                return 3
            case .images:
                return 4
            case .texts:
                return 5
            case .videos:
                return 6
            case .audios:
                return 7
            case .blocks:
                return 8
            }
        }

        var name: String {
            return self.rawValue
        }
    }

    var id: String
    var type: ListType
    var dimensions: Int

    var name: Property
    var order: Int

    var values: [Property]
    var jittering: Property
    var valuesOrder: Property

    var goodValues: [Property]
    var reordenation: [Int]

    var numberOfBlocks: Property
    var lengthOfBlocks: Property

    var typesOfBlocks: Property
    var firstList: Property
    var secondList: Property
    var startingList: Property
    var probChangeList: Property

    var startingBlock: Property
    var probChangeBlock: Property

    var firstBlockFirstList: Property
    var firstBlockSecondList: Property
    var firstBlockStartingList: Property
    var firstBlockProbChangeList: Property

    var secondBlockFirstList: Property
    var secondBlockSecondList: Property
    var secondBlockStartingList: Property
    var secondBlockProbChangeList: Property


    //empty
    init() {
        self.id = UUID().uuidString
        self.name = Property()
        self.order = 0

        self.jittering = Property()
        self.valuesOrder = Property()
        self.values = []
        self.type = .values
        self.dimensions = 1
        self.goodValues = []
        self.reordenation = []

        self.numberOfBlocks = Property()
        self.lengthOfBlocks = Property()

        self.typesOfBlocks = Property()
        self.firstList = Property()
        self.secondList = Property()
        self.startingList = Property()
        self.probChangeList = Property()

        self.startingBlock = Property()
        self.probChangeBlock = Property()

        self.firstBlockFirstList = Property()
        self.firstBlockSecondList = Property()
        self.firstBlockStartingList = Property()
        self.firstBlockProbChangeList = Property()

        self.secondBlockFirstList = Property()
        self.secondBlockSecondList = Property()
        self.secondBlockStartingList = Property()
        self.secondBlockProbChangeList = Property()
    }

    //new 
    init(name: String, order: Int, type: ListType) {
        self.id = UUID().uuidString
        self.dimensions = type.dimensions
        self.name = ListOfValuesData.makeNameProperty(text: name, dimensions: dimensions)
        self.order = order
        self.type = type

        self.jittering = ListOfValuesData.makeJitteringValueProperty(float: 0)
        self.valuesOrder = ListOfValuesData.makeValuesOrderProperty(selected: 0)
        self.values = []
        self.goodValues = []
        self.reordenation = []

        self.numberOfBlocks = ListOfValuesData.makeNumberOfBlocksProperty(float: 1)
        self.lengthOfBlocks = ListOfValuesData.makeLengthOfBlocksProperty(float: 1)

        self.typesOfBlocks = ListOfValuesData.makeTypesOfBlocksProperty(selected: 0)
        self.firstList = ListOfValuesData.makeFirstListProperty(float: 0)
        self.secondList = ListOfValuesData.makeSecondListProperty(float: 0)
        self.startingList = ListOfValuesData.makeStartingListProperty(selected: 0)
        self.probChangeList = ListOfValuesData.makeProbChangeListProperty(float: 0.5)

        self.startingBlock = ListOfValuesData.makeStartingBlockProperty(selected: 0)
        self.probChangeBlock = ListOfValuesData.makeProbChangeBlockProperty(float: 0)

        self.firstBlockFirstList = ListOfValuesData.makeFirstBlockFirstListProperty(float: 0)
        self.firstBlockSecondList = ListOfValuesData.makeFirstBlockSecondListProperty(float: 0)
        self.firstBlockStartingList = ListOfValuesData.makeFirstBlockStartingListProperty(selected: 0)
        self.firstBlockProbChangeList = ListOfValuesData.makeFirstBlockProbChangeListProperty(float: 0.5)

        self.secondBlockFirstList = ListOfValuesData.makeSecondBlockFirstListProperty(float: 0)
        self.secondBlockSecondList = ListOfValuesData.makeSecondBlockSecondListProperty(float: 0)
        self.secondBlockStartingList = ListOfValuesData.makeSecondBlockStartingListProperty(selected: 0)
        self.secondBlockProbChangeList = ListOfValuesData.makeSecondBlockProbChangeListProperty(float: 0.5)
    }

    //copy when duplicating listOfvalues
    init(from oldListOfValues: ListOfValues, name: String, order: Int) {
        self.id = UUID().uuidString
        self.name = ListOfValuesData.makeNameProperty(text: name, dimensions: oldListOfValues.dimensions)
        self.order = order

        self.jittering = Property(from: oldListOfValues.jittering)
        self.valuesOrder = Property(from: oldListOfValues.valuesOrder)
        self.values = oldListOfValues.values.map({ Property(from: $0) })
        self.type = oldListOfValues.type
        self.dimensions = oldListOfValues.dimensions
        self.goodValues = []
        self.reordenation = []

        self.numberOfBlocks = Property(from: oldListOfValues.numberOfBlocks)
        self.lengthOfBlocks = Property(from: oldListOfValues.lengthOfBlocks)

        self.typesOfBlocks = Property(from: oldListOfValues.typesOfBlocks)
        self.firstList = Property(from: oldListOfValues.firstList)
        self.secondList = Property(from: oldListOfValues.secondList)
        self.startingList = Property(from: oldListOfValues.startingList)
        self.probChangeList = Property(from: oldListOfValues.probChangeList)

        self.startingBlock = Property(from: oldListOfValues.startingBlock)
        self.probChangeBlock = Property(from: oldListOfValues.probChangeBlock)

        self.firstBlockFirstList = Property(from: oldListOfValues.firstBlockFirstList)
        self.firstBlockSecondList = Property(from: oldListOfValues.firstBlockSecondList)
        self.firstBlockStartingList = Property(from: oldListOfValues.firstBlockStartingList)
        self.firstBlockProbChangeList = Property(from: oldListOfValues.firstBlockProbChangeList)

        self.secondBlockFirstList = Property(from: oldListOfValues.secondBlockFirstList)
        self.secondBlockSecondList = Property(from: oldListOfValues.secondBlockSecondList)
        self.secondBlockStartingList = Property(from: oldListOfValues.secondBlockStartingList)
        self.secondBlockProbChangeList = Property(from: oldListOfValues.secondBlockProbChangeList)

        self.numberOfBlocks = Property()
        self.lengthOfBlocks = Property()

        self.typesOfBlocks = Property()
        self.firstList = Property()
        self.secondList = Property()
        self.startingList = Property()
        self.probChangeList = Property()

        self.startingBlock = Property()
        self.probChangeBlock = Property()

        self.firstBlockFirstList = Property()
        self.firstBlockSecondList = Property()
        self.firstBlockStartingList = Property()
        self.firstBlockProbChangeList = Property()

        self.secondBlockFirstList = Property()
        self.secondBlockSecondList = Property()
        self.secondBlockStartingList = Property()
        self.secondBlockProbChangeList = Property()
    }

    var jitteringActive: Bool {
        return jittering.float > Constants.epsilon ? true : false
    }

    var valuesString: String {
        return self.values.map({ String($0.string) }).joined(separator: ",")
    }

    var isShuffled: Bool {
        return valuesOrder.selectedValue == 0 ? false : true
    }

    var isRandomBlock: Bool {
        if dimensions == 8 {
            if typesOfBlocks.selectedValue == 0 {
                if startingList.selectedValue == 0 {
                    return true
                }
            } else {
                if startingBlock.selectedValue == 0 || firstBlockStartingList.selectedValue == 0 ||
                    secondBlockStartingList.selectedValue == 0 {
                    return true
                }
            }
        }
        return false
    }



    var detail: String {
        let number = values.count
        if dimensions == 1 {
            if number == 1 {
                return "1 value"
            } else {
                return "\(number) values"
            }
        } else if dimensions == 2 {
            if number == 1 {
                return "1 vector"
            } else {
                return "\(number) vectors"
            }
        } else if dimensions == 3 {
            if number == 1 {
                return "1 color"
            } else {
                return "\(number) colors"
            }
        } else if dimensions == 4 {
            if number == 1 {
                return "1 image"
            } else {
                return "\(number) images"
            }
        } else if dimensions == 5 {
            if number == 1 {
                return "1 text"
            } else {
                return "\(number) texts"
            }
        } else if dimensions == 6 {
            if number == 1 {
                return "1 video"
            } else {
                return "\(number) videos"
            }
        } else if dimensions == 7 {
            if number == 1 {
                return "1 audio"
            } else {
                return "\(number) audios"
            }
        } else if dimensions == 8 {
            let blocks = Int(numberOfBlocks.float)
            let length = Int(lengthOfBlocks.float)
            let trials = blocks * length
            if blocks == 1 {
                if length == 1 {
                    return "\(trials) trial in \(blocks) block"
                } else {
                    return "\(trials) trials in \(blocks) block"
                }
            } else if length == 1 {
                return "\(trials) trials in \(blocks) blocks of \(length) trial each"
            } else {
                return "\(trials) trials in \(blocks) blocks of \(length) trials each"
            }
        } else {
            return ""
        }
    }

    var numberOfTrialsIfBlock: Int {
        return Int(numberOfBlocks.float * lengthOfBlocks.float)
    }

    var blockList: [[ListOfValues]]? {
        guard dimensions == 8 else { return nil }

        if typesOfBlocks.selectedValue == 0 {
            guard let list1 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == firstList.somethingId }) else { return nil }

            guard let list2 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == secondList.somethingId }) else { return nil }

            guard !list1.values.isEmpty && !list2.values.isEmpty else { return nil }

            return [[list1, list2]]
        } else {
            guard let list11 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == firstBlockFirstList.somethingId }) else { return nil }

            guard let list12 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == firstBlockSecondList.somethingId }) else { return nil }

            guard let list21 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == secondBlockFirstList.somethingId }) else { return nil }

            guard let list22 = Flow.shared.test.listsOfValues.first(where: {
                $0.id == secondBlockSecondList.somethingId }) else { return nil }

            guard !list11.values.isEmpty && !list12.values.isEmpty &&
                !list21.values.isEmpty && !list22.values.isEmpty else { return nil }

            return [[list11, list12], [list21, list22]]
        }
    }

    var allValuesBlock: [Property] {
        guard let blockList = blockList else { return [] }

        var values: [Property] = []

        for block2 in blockList {
            for list2 in block2 {
                for value in list2.values {
                    if !values.contains(where: { $0.id == value.id }) {
                        values.append(value)
                    }
                }
            }
        }
        return values
    }

    func calculateGoodValues() -> String {

        if dimensions == 8 {
            goodValues = []
            reordenation = []
        } else {
            goodValues = values
            reordenation = Array(0 ..< values.count)
            guard let order = FixedListOrder(rawValue: valuesOrder.string) else {
                return """
                ERROR: in list: \(self.name.string).
                """
            }
            if order == .shuffled {
                var seedToUse = UInt64.random(in: 0 ... 10000000)

                if let seed = Task.shared.seeds.first(where: { $0.id == self.id }) {
                    seedToUse = seed.value
                } else {

                }

                goodValues = values.shuffled(seed: seedToUse)
                reordenation = reordenation.shuffled(seed: seedToUse)
            }
            guard goodValues.count > 0 else {
                return """
                ERROR: in list: \(self.name.string).
                The list has no values.
                """
            }
        }
        return ""
    }
}
