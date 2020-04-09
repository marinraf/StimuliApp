//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

extension Task {

    func calculateSectionZero(from test: Test) {
        sectionZeroTask = SectionTask()
        let sceneZeroTask = SceneTask()
        var durationInFrames = 0
        switch preview {
        case .no, .previewTest:
            durationInFrames = Flow.shared.settings.frameRate * Constants.sceneZeroDuration
        case .previewScene, .previewStimulus, .variablesSection:
            durationInFrames = Flow.shared.settings.frameRate * Constants.sceneZeroDurationShort
        }
        let checkPoint = SceneTask.CheckPoint(time: durationInFrames,
                                              action: .endScene,
                                              objectNumber: 0,
                                              type: .endScene)

        sceneZeroTask.metalFloats = [[]]
        sceneZeroTask.sineWaveFloats = [Array(repeating: 0, count: Constants.numberOfSineWaveFloats)]
        sceneZeroTask.backgroundFloats = [[]]
        sceneZeroTask.startTimesInFrames = [[]]
        sceneZeroTask.durationTimesInFrames = [[]]
        sceneZeroTask.endTimesInFrames = [[]]
        sceneZeroTask.xSizeMax = [[]]
        sceneZeroTask.ySizeMax = [[]]
        sceneZeroTask.xSizeMax0 = [[]]
        sceneZeroTask.ySizeMax0 = [[]]
        sceneZeroTask.xCenter0 = [[]]
        sceneZeroTask.yCenter0 = [[]]
        sceneZeroTask.active = [[]]
        sceneZeroTask.checkPoints = [[checkPoint]]
        sceneZeroTask.backgroundFloats = [[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1]]
        sceneZeroTask.seeds = [Seed(id: "")]
        sceneZeroTask.activatedBools = [[]]
        sceneZeroTask.name = "sceneZero"
        sceneZeroTask.calculateLongFrames = false

        sectionZeroTask.sceneTasks = [sceneZeroTask]

        if preview == .previewStimulus || preview == .previewScene {
            let condition = Condition(type: nil, n: 0, sectionNumber: 0)
            sectionZeroTask.conditions = [condition]
        } else {
            let firstSection = test.sections.firstIndex(where: { $0.id == test.firstSection.somethingId })
            if let firstSection = firstSection {
                let condition = Condition(type: nil, n: 0, sectionNumber: firstSection)
                sectionZeroTask.conditions = [condition]
            }
        }
    }
}
