//  Stimulios is licensed under the MIT License.
//  Copyright © 2019 Rafael Marín. All rights reserved.

import Foundation

extension Section {

    struct InfoVariable: Codable {
        var name: String
        var object: Object
        var property: Property
        var list: ListOfValues
        var numbers: [Int]
        var valuesToShow: [Property]
        var unit: String
        var jittering: Bool
        var jitteringValue: Float
        var responseDependency: FixedCorrectType?

        var info: String {
            return name + " \(unit): " + valuesToShow.map({ $0.stringWithoutUnit }).joined(separator: ",")
        }
    }

    struct List {
        var numberOfValues: Int
        var bigBlockSize: Int
        var totalSize: Int
        var style: Int
        var groupOrId: String
        var positions: [[Int]]

        var bigBlockNumber: Int {
            return totalSize / bigBlockSize
        }

        var smallBlockSize: Int {
            return bigBlockSize / numberOfValues
        }

        var smallBlockNumberInBig: Int {
            return bigBlockSize / smallBlockSize
        }

        var smallBlockNumber: Int {
            return totalSize / smallBlockSize
        }

        mutating func createPositions(shuffleNumbers: [Int]) {

            positions = []
            var values: [Int] = []

            for i in 0 ..< smallBlockNumber {
                var valuesTemp: [Int] = []
                for _ in 0 ..< smallBlockSize {
                    valuesTemp.append(i % numberOfValues)
                }
                values += valuesTemp
            }

            if shuffleNumbers.isEmpty {
                positions.append(values)
            } else {
                positions.append(AppUtility.reorder(values, with: shuffleNumbers))
            }

        }

        func createShuffleNumbers(seed: UInt64) -> [Int] {
            var values: [Int] = []
            for i in 0 ..< bigBlockNumber {
                let seedItem = UInt64(i + 1) + seed
                let shuffleValues = Array(0 ..< bigBlockSize).shuffled(seed: seedItem)
                values += shuffleValues
            }
            return values
        }

        func createShuffleNumbers2(seed: UInt64) -> [Int] {
            var values: [Int] = []
            for i in 0 ..< smallBlockSize {
                let seedItem = UInt64(i + 1) + seed
                let shuffleValues = Array(i * smallBlockNumber ..< (i + 1) * smallBlockNumber).shuffled(seed: seedItem)
                values += shuffleValues
            }
            return values
        }
    }

    func calculateInfoVariables() -> String {

        infoVariables = []

        guard error == "" else { return error }

        allVariables = self.variables

        var seedToUse = UInt64.random(in: 0 ... 10000000)

        if let seed = Flow.shared.task.seeds.first(where: { $0.id == self.id }) {
            seedToUse = seed.value
        }

        let seed1 = seedToUse * 101
        let seed2 = seedToUse * 257
        let seed3 = seedToUse * 307
        let seed4 = seedToUse * 401
        let seed5 = seedToUse * 631
        let seed6 = seedToUse * 733

        //style 0 is ordered alternate
        //style 1 is shuffled alternate
        //style 2 is ordered high
        //style 3 is ordered medium
        //style 4 is ordered low
        //style 5 is shuffled

        guard totalPossibilities > 0 && totalPossibilities < 1000 else { return "ERROR" }

        guard totalPossibilities < 1000 else { return "ERROR" }

        let totalNumber = totalPossibilities
        var groups: [Int] = []
        var lists: [List] = []

        for (index, variable) in allVariables.enumerated() {
            let seedItem1 = UInt64(index + 1) * seed1
            let seedItem2 = UInt64(index + 1) * seed2

            guard let selection = FixedSelection(rawValue: variable.selection.string) else { return "ERROR" }

            guard let listOfValues = variable.listOfValues else { return "ERROR" }

            if variable.group != -1 && (variable.group == 0 || !groups.contains(variable.group)) {
                groups.append(variable.group)
                let groupOrId = variable.inGroup ? String(variable.group) : variable.id
                let numberOfValues = listOfValues.values.count
                switch selection {
                case .inOrder:
                    let priority = FixedSelectionPriority(rawValue: variable.selection.properties[0].string) ?? .medium
                    var style = 3
                    if priority == .high {
                        style = 2
                    } else if priority == .low {
                        style = 4
                    }
                    let variables = variable.allVariablesInSameGroup.map({ $0.id })
                    if variables.contains(alternate) {
                        style = 0
                    }
                    let values = List(numberOfValues: numberOfValues,
                                      bigBlockSize: 0,
                                      totalSize: totalNumber,
                                      style: style,
                                      groupOrId: groupOrId,
                                      positions: [])
                    lists.append(values)
                case .shuffled:
                    var style = 5
                    let variables = variable.allVariablesInSameGroup.map({ $0.id })
                    if variables.contains(alternate) {
                        style = 1
                    }
                    let values = List(numberOfValues: numberOfValues,
                                      bigBlockSize: 0,
                                      totalSize: totalNumber,
                                      style: style,
                                      groupOrId: groupOrId,
                                      positions: [])
                    lists.append(values)
                case .random:
                    let style = 10000
                    var diff = FixedSelectionDifferent.equal
                    if !variable.selection.properties.isEmpty {
                        diff = FixedSelectionDifferent(rawValue: variable.selection.properties[0].string) ?? .equal
                    }
                    switch diff {
                    case .equal:
                        var values = List(numberOfValues: numberOfValues,
                                          bigBlockSize: 0,
                                          totalSize: totalNumber,
                                          style: style,
                                          groupOrId: groupOrId,
                                          positions: [])
                        var positions: [Int] = []
                        for i in 0 ..< totalNumber {
                            let seed = seedItem1 + UInt64(i + 1)
                            let value = Int.random(seed: seed, minimum: 0, maximum: numberOfValues - 1)
                            positions.append(value)
                        }
                        values.positions.append(positions)
                        lists.append(values)
                    case .different:
                        let numberOfVars = variable.allVariablesInSameGroup.count
                        guard numberOfVars <= numberOfValues else {
                            return """
                            ERROR: variable: \(variable.name) is in a group with other variables.
                            All of the variables of the group are set to have a different value.
                            There are more variables in the group than possible values that the group can take.
                            """
                        }
                        var values = List(numberOfValues: numberOfValues,
                                          bigBlockSize: 0,
                                          totalSize: totalNumber,
                                          style: style,
                                          groupOrId: groupOrId,
                                          positions: [])
                        var positions: [[Int]] = []
                        for i in 0 ..< totalNumber {
                            let seed = seedItem2 + UInt64(i + 1)
                            positions.append(Array(0 ..< numberOfValues).shuffled(seed: seed))
                        }
                        values.positions = positions
                        lists.append(values)
                    }
                case .fixed:
                    let style = 10000
                    var values = List(numberOfValues: numberOfValues,
                                      bigBlockSize: 0,
                                      totalSize: totalNumber,
                                      style: style,
                                      groupOrId: groupOrId,
                                      positions: [])
                    var positions: [[Int]] = []
                    positions.append(Array(0 ..< numberOfValues))
                    values.positions = positions
                    lists.append(values)
                case .correct:
                    let style = 10000
                    var values = List(numberOfValues: numberOfValues,
                                      bigBlockSize: 0,
                                      totalSize: totalNumber,
                                      style: style,
                                      groupOrId: groupOrId,
                                      positions: [])
                    var positions: [[Int]] = []
                    positions.append(Array(0 ..< numberOfValues))
                    values.positions = positions
                    lists.append(values)
                }
            }
        }

        var newLists = lists.sorted(by: { $0.style < $1.style })
        var bigBlockSize = totalNumber
        var shuffleNumbers: [Int] = []
        var shuffleNumbers2: [Int] = []
        for i in 0 ..< newLists.count {
            let seedItem3 = UInt64(i + 1) * seed3
            let seedItem4 = UInt64(i + 1) * seed4

            newLists[i].bigBlockSize = bigBlockSize
            bigBlockSize /= newLists[i].numberOfValues

            if shuffleNumbers.isEmpty && newLists[i].style == 5 {
                shuffleNumbers = newLists[i].createShuffleNumbers(seed: seedItem3)
            }

            if shuffleNumbers2.isEmpty && newLists[i].style == 1 {
                shuffleNumbers2 = newLists[i].createShuffleNumbers2(seed: seedItem4)
            }

            if newLists[i].style < 10 {
                newLists[i].createPositions(shuffleNumbers: shuffleNumbers)
            }
        }

        var newOrder: [Int] = []
        for index in 0 ..< newLists.count {
            if newLists[index].style == 0 {
                for i in 0 ..< newLists[index].smallBlockSize {
                    for j in 0 ..< newLists[index].smallBlockNumber {
                        newOrder.append(j * newLists[index].smallBlockSize + i)
                    }
                }
                newLists[index].positions[0] = AppUtility.reorder(newLists[index].positions[0], with: newOrder)
            } else if newLists[index].style == 1 {
                for i in 0 ..< newLists[index].smallBlockSize {
                    for j in 0 ..< newLists[index].smallBlockNumber {
                        newOrder.append(j * newLists[index].smallBlockSize + i)
                    }
                }
                newOrder = AppUtility.reorder(newOrder, with: shuffleNumbers2)
                newLists[index].positions[0] = AppUtility.reorder(newLists[index].positions[0], with: newOrder)
            } else if newLists[index].style <= 5 {
                newLists[index].positions[0] = AppUtility.reorder(newLists[index].positions[0], with: newOrder)
            }
        }

        var varis: [InfoVariable] = []

        for variable in allVariables {
            guard let selection = FixedSelection(rawValue: variable.selection.string) else { return "ERROR" }
            guard let listOfValues = variable.listOfValues else { return "ERROR" }
            guard let object = variable.object else { return "ERROR" }
            guard let property = variable.property else { return "ERROR" }
            guard let list = newLists.first(where: {
                ($0.groupOrId == String(variable.group) && variable.group != 0)
                    || $0.groupOrId == variable.id || $0.groupOrId == variable.objectId
            }) else { return "ERROR" }

            var positions: [Property] = []
            var numbers: [Int] = []
            var responseDependency: FixedCorrectType?

            switch selection {
            case .random:
                var diff = FixedSelectionDifferent.equal
                if !variable.selection.properties.isEmpty {
                    diff = FixedSelectionDifferent(rawValue: variable.selection.properties[0].string) ?? .equal
                }
                if diff == .equal {
                    let numbers = list.positions[0]
                    positions = AppUtility.reorder(listOfValues.goodValues, with: numbers)
                } else if diff == .different {
                    guard let i = variable.allVariablesInSameGroup.firstIndex(where: { $0 === variable }) else {
                        return "ERROR"
                    }
                    numbers = list.positions.map({ $0[i] })
                }
            case .fixed:
                guard let varProperty = variable.selection.properties.first(where: {
                    $0.somethingId == variable.id
                }) else { return "ERROR" }
                let number = varProperty.float.toInt - 1
                guard number < list.positions[0].count else { return "ERROR" }
                let number2 = list.positions[0][number]
                numbers = Array(repeating: number2, count: totalNumber)
            case .correct:
                guard let correctType = FixedCorrectType(rawValue: variable.selection.properties[0].string) else {
                    return "ERROR"
                }
                responseDependency = correctType
                var number = 0
                if correctType != .zero {
                    guard let varProperty = variable.selection.properties.first(where: {
                        $0.somethingId == variable.id
                    }) else { return "ERROR" }
                    number = varProperty.float.toInt - 1
                }
                guard number < list.positions[0].count else { return "ERROR" }
                let number2 = list.positions[0][number]
                numbers = Array(repeating: number2, count: totalNumber)
            case .inOrder, .shuffled:
                numbers = list.positions[0]
            }

            positions = AppUtility.reorder(listOfValues.goodValues, with: numbers)

            let vari = InfoVariable(name: variable.name,
                                    object: object,
                                    property: property,
                                    list: listOfValues,
                                    numbers: numbers,
                                    valuesToShow: positions.map({ Property(from: $0) }),
                                    unit: property.unitName,
                                    jittering: listOfValues.jitteringActive,
                                    jitteringValue: listOfValues.jittering.float,
                                    responseDependency: responseDependency)
            varis.append(vari)
        }
        for (i, vari) in varis.enumerated() {

            if vari.jittering {
                for (j, item) in vari.valuesToShow.enumerated() {
                    let seed = (seed5 * UInt64(i + 1)) + (seed6 * UInt64(j + 1))
                    let value = vari.jitteringValue

                    let float = Float.random(seed: seed, minimum: -value, maximum: value)
                    let float1 = Float.random(seed: seed + 1, minimum: -value, maximum: value)
                    let float2 = Float.random(seed: seed + 2, minimum: -value, maximum: value)

                    item.float += float
                    item.float1 += float1
                    item.float2 += float2

                    item.unit = vari.property.unit
                    item.timeUnit = vari.property.timeUnit
                    item.timeExponent = vari.property.timeExponent
                    item.unitType = vari.property.unitType
                    item.changeValue(new: [item.float, item.float1, item.float2])
                }
            } else {
                for item in vari.valuesToShow {
                    item.unit = vari.property.unit
                    item.timeUnit = vari.property.timeUnit
                    item.timeExponent = vari.property.timeExponent
                    item.unitType = vari.property.unitType
                    item.changeValue(new: [item.float, item.float1, item.float2])
                }
            }
            if let resp = vari.responseDependency {
                for (index, item) in vari.valuesToShow.enumerated() {
                    if index > 0 || resp == .zero {
                        item.propertyType = .string
                        item.text = "x"
                    }
                }
            }
        }

        self.infoVariables = varis

        if let variable = self.value.variable, let property = variable.property, let object = variable.object,
            let infoVariable = varis.first(where: { $0.property === property && $0.object === object }) {

            guard let valueType = FixedValueType(rawValue: self.value.properties[0].string) else { return "ERROR" }

            if valueType == .same {
                let value = InfoVariable(name: "trialValue",
                                         object: object,
                                         property: property,
                                         list: infoVariable.list,
                                         numbers: infoVariable.numbers,
                                         valuesToShow: infoVariable.valuesToShow,
                                         unit: "",
                                         jittering: false,
                                         jitteringValue: 0,
                                         responseDependency: .zero)
                infoVariables += [value]
            } else {

                let newList = ListOfValues(name: "", order: -1, dimensions: 1)

                newList.values = self.value.properties[0].properties

                let positions = AppUtility.reorder(newList.values, with: infoVariable.numbers)

                let value = InfoVariable(name: "trialValue",
                                         object: object,
                                         property: property,
                                         list: newList,
                                         numbers: infoVariable.numbers,
                                         valuesToShow: positions,
                                         unit: "",
                                         jittering: false,
                                         jitteringValue: 0,
                                         responseDependency: .zero)
                infoVariables += [value]
            }

            let dimensionsTrial = infoVariables.first(where: { $0.name == "trialValue" })?.list.dimensions ?? 0
            var dimensionsResponse = 0
            if let fixedCorrect = FixedCorrect(rawValue: correct.string) {
                if dimensionsTrial != 0 {
                    switch fixedCorrect {
                    case .positionX, .positionY, .positionRadius, .positionAngle, .value:
                        dimensionsResponse = 1
                    case .positionVector:
                        dimensionsResponse = 2
                    }
                }
            }

            guard dimensionsTrial == dimensionsResponse else {

                func dimToString(dimensions: Int) -> String {
                    if dimensions == 1 {
                        return "is a simple variable"
                    } else if dimensions == 2 {
                        return "is a 2d vector"
                    } else if dimensions == 3 {
                        return "is a color (3d vector)"
                    } else {
                        return "does not exist"
                    }
                }

                let trialString = dimToString(dimensions: dimensionsTrial)
                let responseString = dimToString(dimensions: dimensionsResponse)

                return """
                ERROR: trialValue \(trialString) and responseValue \(responseString)
                """
            }

        }
        return ""
    }
}
