//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation



enum TimeFunctions: String, Codable, CaseIterable {

    case linear = "linear"
    case quadratic = "quadratic"
    case sinusoidal = "sinusoidal"
    case rectangleWave = "rectangle wave"
    case triangleWave = "triangle wave"
    case pulse = "pulse"
    case gaussian = "gaussian"
    case gaussianEnergy = "gaussian energy"
    case random = "random"

    var description: String {
        switch self {
        case .linear: return """
            The value changes linearly with time.
            """
        case .quadratic: return """
            The value changes quadratically with time.
            """
        case .sinusoidal: return """
            The value oscillates sinusoidally with time.
            """
        case .rectangleWave: return """
            The value follows a cycle where it is equal to value1 during duration1 and equal to value2 during duration2.
            """
        case .triangleWave: return """
            The value follows a cycle where it changes linearly from value1 to value2 during duration1.
            Then it changes from value2 to value1 during duration2.
            """
        case .pulse: return  """
            The value changes linearly from zero to maximum during rampDuration.
            It is equal to the maximum for centralDuration.
            It changes linearly from maximum to zero during rampDuration.
            """
        case .gaussian: return  """
            The value follows a gaussian function.
            """
        case .gaussianEnergy: return """
            The value follows a gaussian function normalised to have always the same energy (area under the curve) \
            regardless of the standard deviation.
            """
        case .random: return """
            Random values chosen in the interval from value1 to value2. The duration is the same for each one of them.
            """
        }
    }

    func timeFunProperties(for property: Property) -> [Property] {

        let c0 = createProperty(for: property,
                                name: "startMovement",
                                info: "The time in which the movement starts.",
                                measureSame: 0,
                                measureTime: 1,
                                defaultValue: 0)

        let c1 = createProperty(for: property,
                                name: "durationMovement",
                                info: "The duration of the movement.",
                                measureSame: 0,
                                measureTime: 1,
                                defaultValue: 1000)

        switch self {

        case .linear:

            let c2 = createProperty(for: property,
                                    name: "initialValue",
                                    info: "Value when time = 0.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "speed",
                                    info: "Linear increase of value with time.",
                                    measureSame: 1,
                                    measureTime: -1,
                                    defaultValue: 0)

            return [c0, c1, c2, c3]

        case .quadratic:

            let c2 = createProperty(for: property,
                                    name: "initialValue",
                                    info: "Value when time = 0.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "speed",
                                    info: "Linear increase of value with time.",
                                    measureSame: 1,
                                    measureTime: -1,
                                    defaultValue: 0)

            let c4 = createProperty(for: property,
                                    name: "acceleration",
                                    info: "Quadratic increase of value with time.",
                                    measureSame: 1,
                                    measureTime: -2,
                                    defaultValue: 0)

            return [c0, c1, c2, c3, c4]

        case .sinusoidal:

            let c2 = createProperty(for: property,
                                    name: "centralValue",
                                    info: "Value around which the result value oscillates.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "amplitude",
                                    info: "Value of the amplitude of the oscillation.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c4 = createProperty(for: property,
                                    name: "frequency",
                                    info: "Frequency of the oscillation.",
                                    measureSame: 0,
                                    measureTime: -1,
                                    defaultValue: 1)

            let c5 = createProperty(for: property,
                                    name: "phase",
                                    info: "Phase of the oscillation.",
                                    measureSame: 0,
                                    measureTime: 0,
                                    defaultValue: 0)

            return [c0, c1, c2, c3, c4, c5]

        case .rectangleWave:

            let c2 = createProperty(for: property,
                                    name: "value1",
                                    info: "First of the two possible values.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "value2",
                                    info: "Second of the two possible values.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c4 = createProperty(for: property,
                                    name: "duration1",
                                    info: "Duration of the first value.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            let c5 = createProperty(for: property,
                                    name: "duration2",
                                    info: "Duration of the second value.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            return [c0, c1, c2, c3, c4, c5]

        case .triangleWave:

            let c2 = createProperty(for: property,
                                    name: "value1",
                                    info: "First value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "value2",
                                    info: "Second value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c4 = createProperty(for: property,
                                    name: "duration1",
                                    info: "Duration of the linear transition from value1 to value2.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            let c5 = createProperty(for: property,
                                    name: "duration2",
                                    info: "Duration of the linear transition from value2 to value1.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            return [c0, c1, c2, c3, c4, c5]

        case .pulse:
            let c2 = createProperty(for: property,
                                    name: "maximum",
                                    info: "Maximum possible value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "centralDuration",
                                    info: "Duration in which the result is equal to the maximum value.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            let c4 = createProperty(for: property,
                                    name: "rampDuration",
                                    info: "Duration of the linear transition from zero to maximum and viceversa.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            return [c0, c1, c2, c3, c4]

        case .gaussian:

            let c2 = createProperty(for: property,
                                    name: "maximum",
                                    info: "Maximum possible value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "center",
                                    info: "Time in which the result reaches the maximum value.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            let c4 = createProperty(for: property,
                                    name: "deviation",
                                    info: "Standard deviation of the gauss function.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            return [c0, c1, c2, c3, c4]

        case .gaussianEnergy:

            let c2 = createProperty(for: property,
                                    name: "energy",
                                    info: "Value of the integral of the gauss function over the entire real line.",
                                    measureSame: 1,
                                    measureTime: 1,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "center",
                                    info: "Time in which the result reaches the maximum value.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            let c4 = createProperty(for: property,
                                    name: "deviation",
                                    info: "Standard deviation of the gauss function.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 1)

            return [c0, c1, c2, c3, c4]

        case .random:

            let c2 = createProperty(for: property,
                                    name: "value1",
                                    info: "First value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c3 = createProperty(for: property,
                                    name: "value2",
                                    info: "Second value.",
                                    measureSame: 1,
                                    measureTime: 0,
                                    defaultValue: 0)

            let c4 = createProperty(for: property,
                                    name: "duration",
                                    info: "Duration of each one of the randomized values.",
                                    measureSame: 0,
                                    measureTime: 1,
                                    defaultValue: 0)

            return [c0, c1, c2, c3, c4]
        }
    }

    var function: ([Float], Float) -> (Float) {

        return { c, time in

            // correction time from start to end, using constants c[0] and c[1]
            var t = time - c[0]
            if t < 0 {
                t = 0
            } else if t > c[1] {
                t = c[1]
            }

            // different cases constants of the function starting in c[2]
            switch self {
            case .linear:
                return c[2] + c[3] * t

            case .quadratic:
                return c[2] + c[3] * t + c[4] * t * t

            case .sinusoidal:
                return c[2] + c[3] * sin(2 * Float.pi * c[4] * t + c[5])

            case .rectangleWave:
                let value = t.truncatingRemainder(dividingBy: (c[4] + c[5]))
                return value <= c[4] ? c[2] : c[3]

            case .triangleWave:
                let value = t.truncatingRemainder(dividingBy: (c[4] + c[5]))
                if value <= c[4] {
                    return c[2] + value / c[4] * (c[3] - c[2])
                } else {
                    return c[3] - (value - c[4]) / c[5] * (c[3] - c[2])
                }

            case .pulse:
                if t <= c[4] {
                    return t * c[2] / c[4]
                } else if t <= c[4] + c[3] {
                    return c[2]
                } else if t <= 2 * c[4] + c[3] {
                    return c[2] - (t - (c[4] + c[3])) * c[2] / c[4]
                } else {
                    return 0
                }

            case .gaussian:
                return c[2] * exp(-powf((t - c[3]), 2) / 2 / powf(c[4], 2))

            case .gaussianEnergy:
                let const = 1 / c[4] / sqrt(2 * Float.pi)
                return c[2] * const * exp(-powf((t - c[3]), 2) / 2 / powf(c[4], 2))

            case .random:
                let minimTime = max(Flow.shared.settings.delta, c[4])
                let position = UInt64(t / minimTime)
                let minim = min(c[2], c[3])
                let maxim = max(c[2], c[3])
                let seed = (position + 1) * Task.shared.sceneTask.seeds[Task.shared.sectionTask.currentTrial].value
                let value = Float.random(seed: seed, minimum: minim, maximum: maxim)
                return value
            }
        }
    }
}
