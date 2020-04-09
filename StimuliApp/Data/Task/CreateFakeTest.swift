//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import Foundation

extension Task {

    func createTest(stimulus: Stimulus, test: Test) -> Test {

        let newTest = Test(name: "testFake", order: 0)
        let section = Section(name: "sectionFake", order: 0)
        section.trialValue.properties = [Property()] //fake value property
        let scene = Scene(name: "sceneFake", sectionId: section.id, order: 0)
        scene.durationType = SceneData.makeDurationProperty(selected: 1) //scene duration = stimulus duration
        let object = Object(name: "objectFake",
                            stimulus: stimulus,
                            scene: scene,
                            order: 0)

        newTest.sections = [section]
        section.scenes = [scene]
        scene.objects.append(object)

        newTest.frameRate = test.frameRate
        newTest.brightness = test.brightness
        newTest.gamma = test.gamma
        newTest.distance = test.distance
        newTest.listsOfValues = test.listsOfValues

        return newTest
    }
}
