//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

extension Task {

    func getValues(from property: Property,
                   object: Object,
                   position: Int,
                   objectNumber: Int,
                   type: TypeData,
                   update: Update? = nil,
                   parameter: Int? = nil) -> [[Float]] {

        let data = DataToPass(trials: sceneTask.numberOfTrials,
                              position: position,
                              object: object,
                              objectNumber: objectNumber,
                              type: type)

        switch type {
        case .timeDependent:
            return parameterValues(property: property, data: data, update: update, parameter: parameter)
        default:
            break
        }

        switch property.propertyType {
        case .color:
            guard let color = FixedColor(rawValue: property.string) else { return [] }
            switch color {
            case .luminance:
                return luminanceValues(property: property, data: data)
            case .vector3d:
                return vector3dValues(property: property, data: data)
            case .rgb:
                return rgbValues(property: property, data: data)
            }
        case .size2d:
            guard let size = FixedSize2d(rawValue: property.string) else { return [] }
            switch size {
            case .xy:
                return xyValues(property: property, data: data)
            case .vector2d:
                return vector2dValues(property: property, data: data)
            case .cartesian:
                return cartesianValues(property: property, data: data)
            }
        case .position2d:
            guard let pos = FixedPosition2d(rawValue: property.string) else { return [] }
            switch pos {
            case .polar:
                return polarValues(property: property, data: data)
            case .vector2d:
                return vector2dValues(property: property, data: data)
            case .cartesian:
                return cartesianValues(property: property, data: data)
            }
        case .origin2d:
            guard let pos = FixedOrigin2d(rawValue: property.string) else { return [] }
            switch pos {
            case .polar:
                return polarValues(property: property, data: data)
            case .center:
                return centerValues(property: property, data: data)
            case .cartesian:
                return cartesianValues(property: property, data: data)
            }
        default:
            return defaultValues(property: property, data: data)
        }
    }

    func somethingIdValues(property: Property, object: Object) -> [String] {

        var values = Array(repeating: property.somethingId, count: sceneTask.numberOfTrials)
        if property.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === property &&
                $0.object === object }) {
                values = variableTask.values.map({ $0.somethingId })
            }
        }
        return values
    }

    private func defaultValues(property: Property, data: DataToPass) -> [[Float]] {

        var values = Array(repeating: property.float, count: data.trials)

        if property.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === property &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask)
            }
        }
        addUpdates(property: property, data: data)
        return [values]
    }

    private func parameterValues(property: Property, data: DataToPass, update: Update?, parameter: Int?) -> [[Float]] {

        var values = Array(repeating: property.float, count: data.trials)

        if property.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === property &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentParameter(data: data,
                                        variableTask: variableTask,
                                        update: update,
                                        parameter: parameter)
            }
        }
        return [values]
    }

    private func luminanceValues(property: Property, data: DataToPass) -> [[Float]] {
        let newProp = property.properties[0]
        var values = Array(repeating: newProp.float, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask, repetitions: 3)
            }
        }
        addUpdates(property: newProp, data: data, repetitions: 3)

        return [values, values, values]
    }

    private func vector3dValues(property: Property, data: DataToPass) -> [[Float]] {
        let newProp = property.properties[0]
        var values = Array(repeating: newProp.float, count: data.trials)
        var values1 = Array(repeating: newProp.float1, count: data.trials)
        var values2 = Array(repeating: newProp.float2, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object}) {

                values = variableTask.values.map({ $0.float })
                values1 = variableTask.values.map({ $0.float1 })
                values2 = variableTask.values.map({ $0.float2 })

                updateDependentVariable(data: data, variableTask: variableTask, values: 3)
            }
        }
        return [values, values1, values2]
    }

    private func rgbValues(property: Property, data: DataToPass) -> [[Float]] {
        let newProp = property.properties[0]
        let newProp1 = property.properties[1]
        let newProp2 = property.properties[2]
        var values = Array(repeating: newProp.float, count: data.trials)
        var values1 = Array(repeating: newProp1.float, count: data.trials)
        var values2 = Array(repeating: newProp2.float, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask)
            }
        }
        if newProp1.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp1 &&
                $0.object === data.object }) {

                values1 = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask, plus: 1)
            }
        }
        if newProp2.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp2 &&
                $0.object === data.object }) {

                values2 = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask, plus: 2)
            }
        }
        addUpdates(property: newProp, data: data)
        addUpdates(property: newProp1, data: data, plus: 1)
        addUpdates(property: newProp2, data: data, plus: 2)
        return [values, values1, values2]
    }

    private func xyValues(property: Property, data: DataToPass) -> [[Float]] {
        let newProp = property.properties[0]
        var values = Array(repeating: newProp.float, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask, repetitions: 2)
            }
        }
        addUpdates(property: newProp, data: data, repetitions: 2)
        return [values, values]
    }

    private func vector2dValues(property: Property, data: DataToPass) -> [[Float]] {

        let newProp = property.properties[0]
        var values = Array(repeating: newProp.float, count: data.trials)
        var values1 = Array(repeating: newProp.float1, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })
                values1 = variableTask.values.map({ $0.float1 })

                updateDependentVariable(data: data, variableTask: variableTask, values: 2)
            }
        }
        return [values, values1]
    }

    private func cartesianValues(property: Property, data: DataToPass) -> [[Float]] {

        let newProp = property.properties[0]
        let newProp1 = property.properties[1]
        var values = Array(repeating: newProp.float, count: data.trials)
        var values1 = Array(repeating: newProp1.float, count: data.trials)
        if newProp.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {

                values = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask)
            }
        }
        if newProp1.timeDependency == .variable {
            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp1 &&
                $0.object === data.object }) {

                values1 = variableTask.values.map({ $0.float })

                updateDependentVariable(data: data, variableTask: variableTask, plus: 1)
            }
        }
        addUpdates(property: newProp, data: data)
        addUpdates(property: newProp1, data: data, plus: 1)

        return [values, values1]
    }

    private func polarValues(property: Property, data: DataToPass) -> [[Float]] {

        let newProp = property.properties[0]
        let newProp1 = property.properties[1]

        let (x, y) = AppUtility.polarToCartesian(radius: newProp.float, angle: newProp1.float)

        var values = Array(repeating: x, count: data.trials)
        var values1 = Array(repeating: y, count: data.trials)

        if newProp.timeDependency == .variable || newProp1.timeDependency == .variable {

            var varValues = Array(repeating: newProp.float, count: data.trials)
            var varValues1 = Array(repeating: newProp1.float, count: data.trials)

            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp &&
                $0.object === data.object }) {
                varValues = variableTask.values.map({ $0.float })
                updateDependentVariable(data: data, variableTask: variableTask, polarRadius: true)            }

            if let variableTask = sectionTask.variableTasks.first(where: { $0.property === newProp1 &&
                $0.object === data.object }) {
                varValues1 = variableTask.values.map({ $0.float })
                updateDependentVariable(data: data, variableTask: variableTask, polarAngle: true)
            }

            for i in 0 ..< varValues.count {
                (values[i], values1[i]) = AppUtility.polarToCartesian(radius: varValues[i], angle: varValues1[i])
            }
        }

        addPolarUpdates(property: newProp, property1: newProp1, data: data)

        return [values, values1]
    }

    private func centerValues(property: Property, data: DataToPass) -> [[Float]] {

        let values: [Float] = Array(repeating: 0, count: data.trials)
        return [values, values]
    }

    func getOrigin2dValue(from property: Property) -> (x: Float, y: Float) {

        let origin = FixedOrigin2d(rawValue: property.string) ?? .center

        switch origin {
        case .center:
            return (x: 0, y: 0)
        case .cartesian:
            let x = property.properties[0].float
            let y = property.properties[1].float
            return (x: x, y: y)
        case .polar:
            let radius = property.properties[0].float
            let angle = property.properties[1].float
            let (x, y) = AppUtility.polarToCartesian(radius: radius, angle: angle)
            return (x: x, y: y)
        }
    }

    private func updateDependentVariable(data: DataToPass,
                                         variableTask: VariableTask,
                                         repetitions: Int = 1,
                                         values: Int = 1,
                                         plus: Int = 0,
                                         polarRadius: Bool = false,
                                         polarAngle: Bool = false,
                                         sizeChanging: Bool = false,
                                         positionChanging: Bool = false) {

        guard let method = variableTask.responseDependency else { return }

        let dependentVariable = DependentVariable(type: data.type,
                                                  objectNumber: data.objectNumber,
                                                  position: data.position + plus,
                                                  values: values,
                                                  repetitions: repetitions,
                                                  method: method,
                                                  polarRadius: polarRadius,
                                                  polarAngle: polarAngle,
                                                  variableTask: variableTask)

        switch data.type {
        case .metal:
            if data.position == MetalValues.xOrigin ||
                data.position == MetalValues.yOrigin ||
                data.position == MetalValues.xPosition ||
                data.position == MetalValues.yPosition {

                dependentVariable.changingPosition = true

            } else if data.position == MetalValues.xSize ||
                data.position == MetalValues.ySize ||
                data.position == MetalValues.rotation ||
                data.position == MetalValues.borderDistance ||
                data.position == MetalValues.borderThickness {

                dependentVariable.changingSize = true
            }
        default:
            break
        }
        if !sceneTask.dependentVariables.contains(where: { $0.variableTask === dependentVariable.variableTask }) {
            sceneTask.dependentVariables.append(dependentVariable)
        }
    }

    private func updateDependentParameter(data: DataToPass,
                                          variableTask: VariableTask,
                                          update: Update?,
                                          parameter: Int?) {

        guard let method = variableTask.responseDependency else { return }

        let dependentVariable = DependentVariable(type: data.type,
                                                  objectNumber: data.objectNumber,
                                                  position: data.position,
                                                  values: 1,
                                                  repetitions: 1,
                                                  method: method,
                                                  update: update,
                                                  parameter: parameter,
                                                  variableTask: variableTask)

        sceneTask.dependentVariables.append(dependentVariable)
    }

    private func addUpdates(property: Property,
                            data: DataToPass,
                            repetitions: Int = 1,
                            plus: Int = 0) {

        if property.timeDependency == .timeDependent {
            let update = Update()
            update.position = data.position + plus
            update.objectNumber = data.objectNumber
            update.repetitions = repetitions
            update.type = data.type
            update.function = property.timeFunction.function

            var allValues: [[Float]] = []
            for (index, item) in property.properties.enumerated() {
                let values = getValues(from: item,
                                       object: data.object,
                                       position: data.position + plus,
                                       objectNumber: 0,
                                       type: .timeDependent,
                                       parameter: index)
                allValues += values
            }
            update.parameters = allValues.transposed()
            sceneTask.updates.append(update)
        }
    }

    private func addPolarUpdates(property: Property,
                                 property1: Property,
                                 data: DataToPass,
                                 repetitions: Int = 1,
                                 plus: Int = 0) {

        if property.timeDependency == .timeDependent || property1.timeDependency == .timeDependent {

            let update = Update()
            update.position = data.position + plus
            update.objectNumber = data.objectNumber
            update.repetitions = repetitions
            update.type = data.type
            update.function = property.timeFunction.function
            update.function1 = property1.timeFunction.function
            update.polar = true

            var allValues: [[Float]] = []
            for item in property.properties {
                let values = getValues(from: item,
                                       object: data.object,
                                       position: data.position + plus,
                                       objectNumber: 0,
                                       type: data.type)
                allValues += values
            }
            update.parameters = allValues.transposed()

            var allValues1: [[Float]] = []
            for item in property1.properties {
                let values = getValues(from: item,
                                       object: data.object,
                                       position: data.position + plus,
                                       objectNumber: 0,
                                       type: data.type)
                allValues1 += values
            }
            update.parameters1 = allValues1.transposed()

            if update.parameters.isEmpty {
                let count = update.parameters1.count
                update.parameters = Array(repeating: [0, 0, property.float, 0], count: count)
            } else if update.parameters1.isEmpty {
                let count = update.parameters.count
                update.parameters1 = Array(repeating: [0, 0, property.float, 0], count: count)
            }

            sceneTask.updates.append(update)
        }
    }
}
