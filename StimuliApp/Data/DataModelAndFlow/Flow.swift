//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import ARKit
import Network


class Flow {

    static let shared = Flow()

    var screen: Screen
    var tabBarController: UITabBarController
    var tabBarIsMenu: Bool
    var tests: [Test]
    var results: [Result]
    var result: Result
    var test: Test
    var scene: Scene
    var stimulus: Stimulus
    var section: Section
    var object: Object
    var variable: Variable
    var listOfValues: ListOfValues
    var property: Property
    var group: Int
    var settings: Settings
    var frameControl: FrameControl
    var animated: Bool
    private var dataModel: DataModel
    var macApp: NSObjectProtocol?
    var eyeTracker: TrackerDelegate?
    var isAvailableSeeSo = false
    var isAvailableARKit = false
    var possibleEyeTrackers = ["off"]
    var orientation: UIInterfaceOrientation = .portrait
    var cameraXPosition: Double = 0
    var cameraYPosition: Double = 0
    var angle00: Double = 0
    var angle01: Double = 0
    var angle10: Double = 0
    var angle11: Double = 0
    var initScene: Bool = false

    init() {
        self.screen = EmptyScreen()
        self.tabBarController = UITabBarController()
        self.tabBarIsMenu = true
        self.dataModel = DataModel()
        self.test = Test()
        self.result = Result()
        self.scene = Scene()
        self.stimulus = Stimulus()
        self.section = Section()
        self.object = Object()
        self.variable = Variable()
        self.listOfValues = ListOfValues()
        self.property = Property()
        self.group = 0
        self.settings = Settings(device: Device())
        self.frameControl = FrameControl(frameRate: 60, delayAudio: 0)
        self.animated = true
        self.isAvailableSeeSo = importedSeeSo
        self.isAvailableARKit = ARFaceTrackingConfiguration.isSupported
        if isAvailableSeeSo {
            self.possibleEyeTrackers += ["using SeeSo"]
        }
        if isAvailableARKit {
            self.possibleEyeTrackers += ["using ARKit"]
        }
        
        let fetchedTests = dataModel.fetchAllTests()
        let fetchedResults = dataModel.fetchAllResults()
        tests = fetchedTests.sorted(by: { $0.order < $1.order })
        results = fetchedResults.sorted(by: { $0.order < $1.order })

        #if targetEnvironment(macCatalyst)
        Bundle(path: Bundle.main.builtInPlugInsPath?.appending("/MacBundle.bundle") ?? "")?.load()
        self.macApp = NSClassFromString("MacApp") as AnyObject as? NSObjectProtocol
        self.animated = false
        #endif
    }

    var navigationController: UINavigationController? {
        return tabBarController.navigationController ??
            tabBarController.selectedViewController as? UINavigationController
    }

    func requestCameraAccess() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            return true
        } else {
            var isGranted = false
            let semaphore = DispatchSemaphore(value: 0)
            AVCaptureDevice.requestAccess(for: .video) { granted in
                isGranted = granted
                semaphore.signal()
            }
            semaphore.wait()
            return isGranted
        }
    }
    
    
    // MARK: - Changes in properties (for legacy properties and to control screensize)
    func applyChangesInProperties() {
        for test in self.tests {

            if test.createdWithStimuliAppVersion == Constants.version {
                continue
            }

            test.createdWithStimuliAppVersion = Constants.version

            var changeSize = false

            var factorWidth: Float = 1
            var factorHeight: Float = 1

            if let width = test.screenWidth {
                factorWidth = width / Flow.shared.settings.width
                if factorWidth < 1 - Constants.epsilon || factorWidth > 1 + Constants.epsilon {
                    changeSize = true
                }
            } else {
                test.screenWidth = Flow.shared.settings.width
            }

            if let height = test.screenHeight {
                factorHeight = height / Flow.shared.settings.height
                if factorHeight < 1 - Constants.epsilon || factorHeight > 1 + Constants.epsilon {
                    changeSize = true
                }
            } else {
                test.screenHeight = Flow.shared.settings.height

            }

            if changeSize {
                test.screenWidth = Flow.shared.settings.width
                test.screenHeight = Flow.shared.settings.height
                for property in test.allProperties where property.unit == .screenWidthUnits {
                    property.float = property.float / factorWidth
                    property.float1 = property.float1 / factorWidth
                    property.float2 = property.float2 / factorWidth
                }

                for property in test.allProperties where property.unit == .screenHeightUnits {
                    property.float = property.float / factorHeight
                    property.float1 = property.float1 / factorHeight
                    property.float2 = property.float2 / factorHeight
                }
            }


            if test.brightness.unitType == .valueFrom0to1 || test.brightness.name == "brightness" {
                let oldValue = test.brightness.float
                test.brightness = TestData.makeBrightnessProperty(float: oldValue)
            }

            for section in test.sections {
                for property in section.next.properties {
                    if property.info == "when the number of trials responded = n" {
                        property.info = "when the number of trials responded in time = n"
                        if let last = property.name.last {
                            property.name = "when the number of trials responded in time = " + String(last)
                        }
                    }
                }
            }

            for scene in test.scenes {
                let endTime = Property(name: "endTime",
                                         info: """
                                         Maximum time until which it is possible to respond.
                                         """,
                                         propertyType: .simpleFloat,
                                         unitType: .time,
                                         float: 1000)

                let wrongTiming = Property(name: "wrongTiming",
                                         info: """
                                         If 0 it is not possible to respond before startTime or after endTime.
                                         If 1 it is possible to respond before startTime or after endTime but the \
                                         response is considered incorrect.
                                         """,
                                         propertyType: .simpleFloat,
                                         unitType: .activated,
                                         float: 0)


                if let responseType = FixedResponse(rawValue: scene.responseType.string) {
                    if scene.responseType.fixedValues.count == 9 {
                        scene.responseType.fixedValues = FixedResponse.allCases.map { $0.name }
                        if scene.responseType.selectedValue >= 6 {
                            scene.responseType.selectedValue += 3
                        } else if scene.responseType.selectedValue >= 4 {
                            scene.responseType.selectedValue += 2
                        }
                    } else if scene.responseType.fixedValues.count == 10 {
                        scene.responseType.fixedValues = FixedResponse.allCases.map { $0.name }
                        if scene.responseType.selectedValue >= 7 {
                            scene.responseType.selectedValue += 2
                        } else if scene.responseType.selectedValue >= 4 {
                            scene.responseType.selectedValue += 1
                        }
                    }

                    switch responseType {
                    case .none, .keyboard, .keys:
                        break
                    case .leftRight, .topBottom, .touch, .path, .touchObject, .moveObject, .lift,
                         .twoFingersTouch, .touchMultipleObjects:
                        if scene.responseType.properties[1].name != "endTime" {
                            scene.responseType.properties.insert(endTime, at: 1)
                            scene.responseType.properties.insert(wrongTiming, at: 2)
                        }
                        if responseType == .moveObject {
                            if test.createdWithStimuliAppVersion ?? 0 < 1.8 {
                                SceneData.addPropertiesToEndPathResponse(property: scene.responseType.properties[5])
                            }
                        }
                    }
                }
            }
            saveTest(test)
        }
    }

    // MARK: - Full Screen Mac
    func enterFullScreen() {
        if let macApp = macApp {
            macApp.perform(NSSelectorFromString("enterFullScreen"))
        }
    }

    func exitFullScreen() {
        if let macApp = macApp {
            macApp.perform(NSSelectorFromString("exitFullScreen"))
        }
    }

    // MARK: - Navigate
    func initTabControllerTest() {
        guard let tabController = tabBarController as? NavigationControllerTab else { return }
        tabController.settingViewControllersTest()
    }

    func initTabControllerMenu() {
        guard let tabController = tabBarController as? NavigationControllerTab else { return }
        tabController.settingViewControllersMenu()
    }

    func navigate(to screen: Screen?) {
        guard let navigationController = navigationController, let screen = screen else { return }

        self.screen = screen

        switch screen.style {
        case .main:
            break
        case .menu:
            let newViewController = MenuViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .modify:
            let newViewController = ModifyViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .infoExport:
            let newViewController = InfoExportViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .content:
            let newViewController = ContentViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .display:
            let newViewController = DisplayViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .displayPreview:
            let newViewController = DisplayPreviewViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .select:
            let newViewController = SelectViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        case .calibration:
            let newViewController = CalibrationViewController()
            navigationController.pushViewController(newViewController, animated: self.animated)
        }
        deletePreviousToLastViewControllerIfIsSelectViewControllerOrSeed()
    }

    func navigateBack() {
        guard let navigationController = navigationController else { return }
        let count = navigationController.viewControllers.count
        guard count > 1  else {
            self.tabBarController.selectedIndex = 0
            return
        }

        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.popViewController(animated: self.animated)
    }

    private func deletePreviousToLastViewControllerIfIsSelectViewControllerOrSeed() {
        guard let navigationController = navigationController else { return }
        let count = navigationController.viewControllers.count
        guard count > 2  else { return }

        if navigationController.viewControllers[count - 2] is SelectViewController {
            navigationController.viewControllers.remove(at: count - 2)
        } else if let navi = navigationController.viewControllers[count - 2] as? ModifyViewController {
            if navi.modify.isSeed {
                navigationController.viewControllers.remove(at: count - 2)
            }
        }
    }

    // MARK: - Saving
    func saveTest(_ test: Test) {
        _ = dataModel.saveTest(test)
    }

    func saveResult(_ result: Result) {
        _ = dataModel.saveResult(result)
    }

    func createSaveAndSelectNewResult(_ result: Result) -> Bool {
        guard dataModel.saveNewResult(result) else { return false }
        self.result = result
        self.results.append(result)
        return true
    }

    func createSaveAndSelectNewTest() -> Bool {
        let name = firstAvailableTestName()
        let order = tests.count
        let test = Test(name: name, order: order)
        guard dataModel.saveNewTest(test) else { return false }
        self.test = test
        self.tests.append(test)
        return true
    }

    func createSaveAndSelectNewScene() -> Bool {
        let name = firstAvailableSceneName()
        let order = section.scenes.count
        let scene = Scene(name: name, sectionId: section.id, order: order)
        section.scenes.append(scene)
        guard dataModel.saveTest(test) else { return false }
        self.scene = scene
        return true
    }

    func createSaveAndSelectNewStimulus() -> Bool {
        let name = firstAvailableStimulusName()
        let order = test.stimuli.count
        let stimulus = Stimulus(name: name, order: order)
        test.stimuli.append(stimulus)
        guard dataModel.saveTest(test) else { return false }
        self.stimulus = stimulus
        return true
    }

    func createSaveAndSelectNewSection() -> Bool {
        let name = firstAvailableSectionName()
        let order = test.sections.count
        let section = Section(name: name, order: order)
        test.sections.append(section)
        guard dataModel.saveTest(test) else { return false }
        self.section = section
        return true
    }

    func createSaveAndSelectNewListOfValues(type: ListOfValues.ListType) -> Bool {
        let name = firstAvailableListOfValuesName(type: type)
        let order = test.listsOfValues.count
        let listOfValues = ListOfValues(name: name, order: order, type: type)
        test.listsOfValues.append(listOfValues)
        guard dataModel.saveTest(test) else { return false }
        self.listOfValues = listOfValues
        return true
    }

    func createAndSaveNewTest(from test: Test) -> Bool {
        let name = firstAvailableTestName(from: test.name.string)

        guard let newTest = dataModel.fetchTestFrom(oldTest: test) else { return false }
        newTest.name = TestData.makeNameProperty(text: name)
        newTest.order = tests.count
        newTest.id = UUID().uuidString
        guard dataModel.saveNewTest(newTest) else { return false }
        self.tests.append(newTest)
        moveTests(newTest.order, to: test.order + 1)
        return true
    }

    func createAndSaveNewTest(from data: Data) -> Bool {
        if let test = Encode.jsonDataToTest(jsonData: data) {
            let name = firstAvailableTestName2(from: test.name.string)
            test.name = TestData.makeNameProperty(text: name)
            
            let selectedFrameRate = test.frameRate.selectedValue
            test.frameRate = TestData.makeFrameRateProperty(frameRate: Flow.shared.settings.maximumFrameRate,
                                                            selected: selectedFrameRate)
            
            let eyeTrackerName = test.eyeTracker?.string ?? "off"
            test.eyeTracker = TestData.makeEyeTrackerProperty(fixedValues: Flow.shared.possibleEyeTrackers, value: eyeTrackerName)
            

            test.id = UUID().uuidString
            test.order = tests.count
            if dataModel.saveNewTest(test) {
                tests.append(test)
                return true
            }
        }
        return false
    }

    func createAndSaveNewScene(from scene: Scene) -> Bool {
        let name = firstAvailableSceneName(from: scene.name.string)
        let order = section.scenes.count
        let newScene = Scene(from: scene, sectionId: section.id, name: name, order: order)
        section.scenes.append(newScene)
        guard dataModel.saveTest(test) else { return false }
        self.scene = newScene
        moveScenes(newScene.order, to: scene.order + 1)
        return true
    }

    func createAndSaveNewStimulus(from stimulus: Stimulus) -> Bool {
        let name = firstAvailableStimulusName(from: stimulus.name.string)
        let order = test.stimuli.count
        let newStimulus = Stimulus(from: stimulus, name: name, order: order)
        test.stimuli.append(newStimulus)
        guard dataModel.saveTest(test) else { return false }
        moveStimuli(newStimulus.order, to: stimulus.order + 1)
        return true
    }

    func createAndSaveNewSection(from section: Section) -> Bool {
        let name = firstAvailableSectionName(from: section.name.string)
        let order = test.sections.count
        let newSection = Section(from: section, name: name, order: order)
        test.sections.append(newSection)
        if newSection.isShuffled {
            let property = TestData.makePropertyToAddToRandomness(name: newSection.id)
            test.randomness.properties.append(property)
        }
        guard dataModel.saveTest(test) else { return false }
        moveSections(newSection.order, to: section.order + 1)
        return true
    }

    func createAndSaveNewObject(from object: Object) -> Bool {
        let name = firstAvailableObjectName()
        let order = scene.objects.count
        guard let stimulus = object.stimulus else { return false }
        guard let scene = object.scene else { return false }
        let newObject = Object(name: name, stimulus: stimulus, scene: scene, order: order)
        scene.objects.append(newObject)
        if let response = FixedResponse(rawValue: scene.responseType.string) {
            if response == .touchObject || response == .touchMultipleObjects {
                let property = SceneData.makePropertyToAddToResponse(object: newObject)
                scene.responseType.properties.append(property)
            } else if response == .moveObject {
                let property = SceneData.makePropertyToAddToResponse2(object: newObject)
                scene.responseType.properties.append(property)
            }
        }
        guard dataModel.saveTest(test) else { return false }
        moveObjects(newObject.order, to: object.order + 1)
        return true
    }

    func createSaveAndSelectNewObject(from stimulus: Stimulus, scene: Scene) -> Bool {
        let name = firstAvailableObjectName()
        let order = scene.objects.count
        let object = Object(name: name, stimulus: stimulus, scene: scene, order: order)
        scene.objects.append(object)
        if let response = FixedResponse(rawValue: scene.responseType.string) {
            if response == .touchObject || response == .moveObject || response == .touchMultipleObjects {
                if scene.movableObjects.contains(where: { $0 === object }) {
                    let property = SceneData.makePropertyToAddToResponse(object: object)
                    scene.responseType.properties.append(property)
                }
            }
        }
        guard dataModel.saveTest(test) else { return false }
        self.object = object
        return true
    }

    func createAndSaveNewListOfValues(from listOfvalues: ListOfValues) -> Bool {
        let name = firstAvailableListOfValuesName(from: listOfvalues.name.string)
        let order = test.listsOfValues.count
        let newListOfValues = ListOfValues(from: listOfvalues, name: name, order: order)
        test.listsOfValues.append(newListOfValues)
        if newListOfValues.isShuffled || newListOfValues.isRandomBlock {
            let property = TestData.makePropertyToAddToRandomness(name: newListOfValues.id)
            test.randomness.properties.append(property)
        }
        guard dataModel.saveTest(test) else { return false }
        self.listOfValues = newListOfValues
        moveListsOfValues(newListOfValues.order, to: listOfvalues.order + 1)
        return true
    }

    // MARK: - Delete
    func deleteDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    func deleteAllTests() {
        dataModel.deleteAllTests()
        tests = []
    }

    func deleteAllResults() {
        dataModel.deleteAllResults()
        results = []
    }

    func deleteAllFiles() {
        FilesAndPermission.deleteAllFilesInDocuments()
    }

    func deleteTestTexts() -> (String, String) {
        let title = "Delete test"
        let text = Texts.deleteTest
        return (title, text)
    }

    func deleteTest(_ test: Test) {
        guard dataModel.deleteTest(test) else { return }
        tests = tests.filter({ $0 !== test })
        for otherTest in tests where otherTest.order > test.order {
            otherTest.order -= 1
            saveTest(otherTest)
        }
    }

    func deleteResultTexts() -> (String, String) {
        let title = "Delete result"
        let text = Texts.deleteResult
        return (title, text)
    }

    func deleteResult(_ result: Result) {
        guard dataModel.deleteResult(result) else { return }
        results = results.filter({ $0 !== result })
        for otherResult in results where otherResult.order > result.order {
            otherResult.order -= 1
            saveResult(otherResult)
        }
    }

    func deleteStimulusTexts(_ stimulus: Stimulus) -> (String, String) {
        let title = "Delete stimulus"
        var text = Texts.deleteStimulus
        var strings: [String] = []

        for object in test.objects where object.stimulus === stimulus {
            strings.append(object.name.string)
        }

        if !strings.isEmpty {
            text += "\n" + "\n" + strings.joined(separator: ", ")
        }
        return (title, text)
    }

    func deleteStimulus(_ stimulus: Stimulus) {
        for object in test.objects where object.stimulus === stimulus {
            deleteObject(object)
        }
        test.stimuli = test.stimuli.filter({ $0 !== stimulus })
        for otherStimulus in test.stimuli where otherStimulus.order > stimulus.order {
            otherStimulus.order -= 1
        }
        saveTest(test)
    }

    func deleteSectionTexts() -> (String, String) {
        let title = "Delete section"
        let text = Texts.deleteSection
        return (title, text)
    }

    func deleteSection(_ section: Section) {
        for scene in section.scenes {
            deleteScene(scene)
        }
        test.sections = test.sections.filter({ $0 !== section })
        for otherSection in test.sections where otherSection.order > section.order {
            otherSection.order -= 1
        }
        for otherSection in test.sections where otherSection.next.somethingId == section.id {
            otherSection.next.somethingId = ""
        }
        test.randomness.properties = test.randomness.properties.filter({ $0.name != section.id })
        saveTest(test)
    }

    func deleteSceneTexts() -> (String, String) {
        let title = "Delete scene"
        let text = Texts.deleteScene
        return (title, text)
    }

    func deleteScene(_ scene: Scene) {
        for object in scene.objects {
            deleteObject(object)
        }
        if let section = scene.section {
            section.scenes = section.scenes.filter({ $0 !== scene })
            for otherScene in section.scenes where otherScene.order > scene.order {
                otherScene.order -= 1
            }
            if section.responseValue.somethingId == scene.id {
                section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
            }
        }
        saveTest(test)
    }

    func deleteConditionTexts() -> (String, String) {
        let title = "Delete condition"
        let text = Texts.deleteCondition
        return (title, text)
    }

    func deleteCondition(_ condition: Property) {
        Flow.shared.section.next.properties = Flow.shared.section.next.properties.filter({ $0 !== condition })
        for (index, element) in Flow.shared.section.next.properties.enumerated() {
            element.listOrder = index
        }
        saveTest(test)
    }

    func deleteObjectTexts() -> (String, String) {
        let title = "Delete object"
        let text = Texts.deleteObject
        return (title, text)
    }

    func deleteObject(_ object: Object) {
        for variable in object.variables {
            deleteVariable(variable)
        }
        if let scene = object.scene {
            scene.objects = scene.objects.filter({ $0 !== object })
            for otherObject in scene.objects where otherObject.order > object.order {
                otherObject.order -= 1
            }
            scene.responseType.properties = scene.responseType.properties.filter({ $0.somethingId != object.id })
        }
        saveTest(test)
    }

    func deleteObjectMaintainingOrder(_ object: Object) {
        for variable in object.variables {
            deleteVariable(variable)
        }
        if let scene = object.scene {
            scene.objects = scene.objects.filter({ $0 !== object })
            scene.responseType.properties = scene.responseType.properties.filter({ $0.somethingId != object.id })
        }
        saveTest(test)
    }

    func deleteVariable(_ variable: Variable) {
        if let object = variable.object {
            object.variables = object.variables.filter({ $0 !== variable })
        }
        for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {
            section.trialValue.somethingId = ""
            section.trialValue.addProperties()
            section.responseValue = SectionData.makeResponseValueProperty(selected: 0)
        }
        deleteVariableFromGroup(variable)
        saveTest(test)
    }

    func deleteVariableFromGroup(_ variable: Variable) {
        let variables = variable.otherVariablesInSameGroup(section: section)
        for element in variables {
            element.selection.properties = element.selection.properties.filter({ $0.somethingId != variable.id })
        }
        variable.group = 0
        variable.selection = VariableData.makeSelectionProperty(selected: 0)
        if let select = FixedSelection(rawValue: variable.selection.string) {
            if select == .random {
                variable.selection.properties = []
            }
        }
        if variables.count == 1 {
            variables[0].group = 0
            variables[0].selection.somethingId = String(variables[0].group)
            Flow.shared.group = 0
            if let select = FixedSelection(rawValue: variables[0].selection.string) {
                if select == .random {
                    variables[0].selection.properties = []
                }
            }
        }
        saveTest(test)
    }

    func deleteListOfValuesTexts(_ listOfValue: ListOfValues) -> (String, String) {
        let title = "Delete list"
        var text = Texts.deleteList
        var strings: [String] = []

        for variable in test.allVariables where variable.listOfValuesId == listOfValues.id {
            strings.append(variable.name)
        }

        if !strings.isEmpty {
            text += "\n" + "\n" + strings.joined(separator: ", ")
        }
        return (title, text)
    }

    func deleteListOfValues(_ listOfValues: ListOfValues) {
        for variable in test.allVariables where variable.listOfValuesId == listOfValues.id {
            variable.listOfValuesId = ""
            for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {
                section.trialValue.somethingId = ""
                section.trialValue.addProperties()
            }
        }

        if let vari = test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
            for section in test.sections where section.trialValue.somethingId == vari.id {
                if section.trialValue.properties.count > 0 {
                    section.trialValue.somethingId = ""
                    section.trialValue.addProperties()
                }
            }
        }

        test.listsOfValues = test.listsOfValues.filter({ $0 !== listOfValues })
        for otherList in test.listsOfValues where otherList.order > listOfValues.order {
            otherList.order -= 1
        }
        test.randomness.properties = test.randomness.properties.filter({ $0.name != listOfValues.id })
        saveTest(test)
    }

    func deleteListOfValuesValue(order: Int) {

        var keys: [String] = []

        if let vari = test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
            if let values = vari.listOfValues?.allValuesBlock {
                keys = values.map({ $0.id })
            }
        }

        for variable in test.allVariables where variable.listOfValuesId == listOfValues.id {
            for section in test.sections where section.trialValue.somethingId == variable.id {
                if section.trialValue.properties.count > 0 {
                    if let valueType = FixedValueType(rawValue: section.trialValue.properties[0].string) {
                        if valueType == .other {
                            section.trialValue.properties[0].properties.remove(at: order)
                        }
                    }
                }
            }
        }

        listOfValues.values.remove(at: order)
        for (index, element) in listOfValues.values.enumerated() {
            element.listOrder = index
            if listOfValues.dimensions > 3 {
                element.float = Float(element.listOrder + 1)
            }
        }

        if let vari = test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
            for section in test.sections where section.trialValue.somethingId == vari.id {
                SectionData.addPropertiesToValueTypeWithDict(property: section.trialValue.properties[0], oldKeys: keys)
            }
        }

        for variable in test.allVariables where variable.listOfValuesId == Flow.shared.listOfValues.id {
            for section in test.sections where section.trialValue.somethingId == variable.id {
                SectionData.changeValueNames(property: section.trialValue.properties[0],
                                             list: Flow.shared.listOfValues)
            }
        }

        saveTest(test)
    }

    // MARK: - Move
    func moveResults(_ first: Int, to second: Int) {
        let resultA = results[first]
        resultA.order = second
        _ = dataModel.saveResult(resultA)
        if first < second {
            for i in first + 1 ... second {
                let result = results[i]
                result.order -= 1
                _ = dataModel.saveResult(result)
            }
        } else if first > second {
            for i in second ..< first {
                let result = results[i]
                result.order += 1
                _ = dataModel.saveResult(result)
            }
        }
        results = results.sorted(by: { $0.order < $1.order })
    }

    func moveTests(_ first: Int, to second: Int) {
        let testA = tests[first]
        testA.order = second
        _ = dataModel.saveTest(testA)
        if first < second {
            for i in first + 1 ... second {
                let test = tests[i]
                test.order -= 1
                _ = dataModel.saveTest(test)
            }
        } else if first > second {
            for i in second ..< first {
                let test = tests[i]
                test.order += 1
                _ = dataModel.saveTest(test)
            }
        }
        tests = tests.sorted(by: { $0.order < $1.order })
    }

    func moveScenes(_ first: Int, to second: Int) {
        let sceneA = section.scenes[first]
        sceneA.order = second
        if first < second {
            for i in first + 1 ... second {
                let scene = section.scenes[i]
                scene.order -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let scene = section.scenes[i]
                scene.order += 1
            }
        }
        section.scenes = section.scenes.sorted(by: { $0.order < $1.order })
        checkVariablesOrder()
        _ = dataModel.saveTest(test)
    }

    func moveStimuli(_ first: Int, to second: Int) {
        let stimulusA = test.stimuli[first]
        stimulusA.order = second
        if first < second {
            for i in first + 1 ... second {
                let stimulus = test.stimuli[i]
                stimulus.order -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let stimulus = test.stimuli[i]
                stimulus.order += 1
            }
        }
        test.stimuli = test.stimuli.sorted(by: { $0.order < $1.order })
        _ = dataModel.saveTest(test)
    }

    func moveSections(_ first: Int, to second: Int) {
        let sectionA = test.sections[first]
        sectionA.order = second
        if first < second {
            for i in first + 1 ... second {
                let section = test.sections[i]
                section.order -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let section = test.sections[i]
                section.order += 1
            }
        }
        test.sections = test.sections.sorted(by: { $0.order < $1.order })
        _ = dataModel.saveTest(test)
    }

    func moveObjects(_ first: Int, to second: Int) {
        let realSecond = second == 0 ? 1 : second
        let objectA = scene.objects[first]
        objectA.order = realSecond
        if first < realSecond {
            for i in first + 1 ... realSecond {
                let object = scene.objects[i]
                object.order -= 1
            }
        } else if first > realSecond {
            for i in realSecond ..< first {
                let object = scene.objects[i]
                object.order += 1
            }
        }
        scene.objects = scene.objects.sorted(by: { $0.order < $1.order })
        if let response = FixedResponse(rawValue: scene.responseType.string) {
            if response == .moveObject || response == .touchObject {
                if let position = scene.responseType.properties.firstIndex(where: { $0.object != nil }) {
                    var i = position
                    for object in scene.objects {
                        for (index, element) in scene.responseType.properties.enumerated() {
                            if element.object === object {
                                scene.responseType.properties.remove(at: index)
                                scene.responseType.properties.insert(element, at: i)
                                i += 1
                            }
                        }
                    }
                }
            }
        }
        checkVariablesOrder()
        _ = dataModel.saveTest(test)
    }

    func moveListsOfValues(_ first: Int, to second: Int) {
        let valuesA = test.listsOfValues[first]
        valuesA.order = second
        if first < second {
            for i in first + 1 ... second {
                let listsOfValues = test.listsOfValues[i]
                listsOfValues.order -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let listsOfValues = test.listsOfValues[i]
                listsOfValues.order += 1
            }
        }
        test.listsOfValues = test.listsOfValues.sorted(by: { $0.order < $1.order })
        _ = dataModel.saveTest(test)
    }

    func moveValuesValues(_ first: Int, to second: Int) {

        var keys: [String] = []

        if let vari = test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
            if let values = vari.listOfValues?.allValuesBlock {
                keys = values.map({ $0.id })
            }
        }

        if listOfValues.dimensions <= 3 {
            for variable in test.allVariables where variable.listOfValuesId == listOfValues.id {
                for section in Flow.shared.test.sections where section.trialValue.somethingId == variable.id {

                    moveValuesSection(first, to: second, section: section)
                }
            }
        }

        let valueA = listOfValues.values[first]
        valueA.listOrder = second
        if first < second {
            for i in first + 1 ... second {
                let value = listOfValues.values[i]
                value.listOrder -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let value = listOfValues.values [i]
                value.listOrder += 1
            }
        }
        listOfValues.values = listOfValues.values.sorted(by: { $0.listOrder < $1.listOrder })

        if let vari = test.allVariables.first(where: { $0.listOfValues?.dimensions == 8 }) {
            for section in test.sections where section.trialValue.somethingId == vari.id {
                SectionData.addPropertiesToValueTypeWithDict(property: section.trialValue.properties[0], oldKeys: keys)
            }
        }

        _ = dataModel.saveTest(test)
    }

    func moveValuesSection(_ first: Int, to second: Int, section: Section) {

        if section.trialValue.properties.count > 0 {
            if let valueType = FixedValueType(rawValue: section.trialValue.properties[0].string) {
                if valueType == .other {
                    for (index, property) in section.trialValue.properties[0].properties.enumerated() {
                        property.listOrder = index
                    }
                    let valueA = section.trialValue.properties[0].properties[first]
                    valueA.listOrder = second
                    if first < second {
                        for i in first + 1 ... second {
                            let value = section.trialValue.properties[0].properties[i]
                            value.listOrder -= 1
                        }
                    } else if first > second {
                        for i in second ..< first {
                            let value = section.trialValue.properties[0].properties [i]
                            value.listOrder += 1
                        }
                    }
                    section.trialValue.properties[0].properties.sort(by: { $0.listOrder < $1.listOrder })
                    _ = dataModel.saveTest(test)
                }
            }
        }
    }

    func moveConditions(_ first: Int, to second: Int) {
        let conditionA = section.next.properties[first]
        conditionA.listOrder = second
        if first < second {
            for i in first + 1 ... second {
                let condition = section.next.properties[i]
                condition.listOrder -= 1
            }
        } else if first > second {
            for i in second ..< first {
                let condition = section.next.properties[i]
                condition.listOrder += 1
            }
        }
        section.next.properties = section.next.properties.sorted(by: { $0.listOrder < $1.listOrder })
        _ = dataModel.saveTest(test)
    }

    private func checkVariablesOrder() {
        for variable in section.allVariables where variable.inGroup {

            if let select = FixedSelection(rawValue: variable.selection.string) {
                if select == .fixed || select == .correct {
                    var i = 0
                    for vari in section.allVariables {
                        for (index, element) in variable.selection.properties.enumerated() {
                            if element.variable === vari {
                                variable.selection.properties.remove(at: index)
                                variable.selection.properties.insert(element, at: i)
                                i += 1
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Available names
    private func firstAvailableTestName() -> String {
        let usedNames = tests.map({ $0.name.string })
        for i in 1 ..< 1000 {
            let newName = "test\(i)"
            if !usedNames.contains(newName) {
                return newName
            }
        }
        return UUID().uuidString
    }

    private func firstAvailableSceneName() -> String {
        let usedNames = section.scenes.map({ $0.name.string })
        for i in 1 ..< 1000 {
            let newName = "scene\(i)"
            if !usedNames.contains(newName) {
                return newName
            }
        }
        return UUID().uuidString
    }

    private func firstAvailableStimulusName() -> String {
        let usedNames = test.stimuli.map({ $0.name.string })
        for i in 1 ..< 1000 {
            let newName = "stimulus\(i)"
            if !usedNames.contains(newName) {
                return newName
            }
        }
        return UUID().uuidString
    }

    private func firstAvailableSectionName() -> String {
        let usedNames = test.sections.map({ $0.name.string })
        for i in 1 ..< 1000 {
            let newName = "section\(i)"
            if !usedNames.contains(newName) {
                return newName
            }
        }
        return UUID().uuidString
    }

    private func firstAvailableObjectName() -> String {
        let usedNames = scene.objects.map({ $0.name.string })
        for i in 1 ..< 1000 {
            let newName = "object\(i)"
            if !usedNames.contains(newName) {
                return newName
            }
        }
        return UUID().uuidString
    }

    private func firstAvailableListOfValuesName(type: ListOfValues.ListType) -> String {
        let name = type.name

        switch type {
        case .audios, .videos, .texts, .images, .blocks:
            return name
        case .values, .vectors, .colors:
            let usedNames = test.listsOfValues.map({ $0.name.string })
            for i in 1 ..< 1000 {
                let newName = "\(name)\(i)"
                if !usedNames.contains(newName) {
                    return newName
                }
            }
            return UUID().uuidString
        }
    }

    private func firstAvailableTestName(from name: String) -> String {
        let usedNames = tests.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableTestName(from: name + "Copy")
        }
    }

    private func firstAvailableTestName2(from name: String) -> String {
        let usedNames = tests.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableTestName2(from: name + "Imported")
        }
    }

    private func firstAvailableSceneName(from name: String) -> String {
        let usedNames = section.scenes.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableSceneName(from: name + "Copy")
        }
    }

    private func firstAvailableStimulusName(from name: String) -> String {
        let usedNames = test.stimuli.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableStimulusName(from: name + "Copy")
        }
    }

    private func firstAvailableSectionName(from name: String) -> String {
        let usedNames = test.sections.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableSectionName(from: name + "Copy")
        }
    }

    private func firstAvailableListOfValuesName(from name: String) -> String {
        let usedNames = test.listsOfValues.map({ $0.name.string })
        if !usedNames.contains(name) {
            return name
        } else {
            return firstAvailableListOfValuesName(from: name + "Copy")
        }
    }
}

