//  StimuliApp is licensed under the MIT License.
//  Copyright © 2020 Rafael Marín. All rights reserved.

import UIKit
import CoreData

@objc(SavedTest)
public class SavedTest: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var dataString: String

    @nonobjc public class func testFetchRequest() -> NSFetchRequest<SavedTest> {
        return NSFetchRequest<SavedTest>(entityName: "SavedTest")
    }
}

@objc(SavedMedia)
public class SavedMedia: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var dataString: String

    @nonobjc public class func mediaFetchRequest() -> NSFetchRequest<SavedMedia> {
        return NSFetchRequest<SavedMedia>(entityName: "SavedMedia")
    }
}

@objc(SavedResult)
public class SavedResult: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var dataString: String

    @nonobjc public class func resultFetchRequest() -> NSFetchRequest<SavedResult> {
        return NSFetchRequest<SavedResult>(entityName: "SavedResult")
    }
}

class DataModel {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Managing Results
    func saveResult(_ result: Result) -> Bool {
        guard let resultToSave = fetchSavedResult(from: result) else { return false }
        guard let jsonString = Encode.resultToJsonString(result: result) else { return false }

        resultToSave.dataString = jsonString
        resultToSave.id = result.id
        saveContext()
        return true
    }

    func saveNewResult(_ result: Result) -> Bool {
        let context = persistentContainer.viewContext

        let resultToSave = SavedResult(entity: SavedResult.entity(), insertInto: context)
        guard let jsonString = Encode.resultToJsonString(result: result) else { return false }

        resultToSave.dataString = jsonString
        resultToSave.id = result.id
        saveContext()
        return true
    }

    func deleteResult(_ result: Result) -> Bool {
        guard let savedResult = fetchSavedResult(from: result) else { return false }
        let context = persistentContainer.viewContext
        context.delete(savedResult)
        saveContext()
        return true
    }

    func fetchAllResults() -> [Result] {
        let savedResults = fetchAllSavedResults()
        var results: [Result] = []

        for savedResult in savedResults {
            if let result = Encode.jsonStringToResult(jsonString: savedResult.dataString) {
                results.append(result)
            }
        }
        return results
    }

    func fetchResultFrom(oldResult: Result) -> Result? {
        let newResults = fetchAllResults()
        let newResult = newResults.first(where: { $0.id == oldResult.id })
        return newResult
    }

    func deleteAllResults() {
        let savedResults = fetchAllSavedResults()
        let context = persistentContainer.viewContext
        for element in savedResults {
            context.delete(element)
        }
        saveContext()
    }

    private func fetchAllSavedResults() -> [SavedResult] {
        var savedResults: [SavedResult] = []
        let context = persistentContainer.viewContext

        let fetchRequest = SavedResult.resultFetchRequest()

        do {
            savedResults = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return savedResults
    }

    private func fetchSavedResult(from result: Result) -> SavedResult? {
        let savedResults = fetchAllSavedResults()
        let savedResult = savedResults.first(where: { $0.id == result.id })
        return savedResult
    }

    // MARK: - Managing Tests
    func saveTest(_ test: Test) -> Bool {
        guard let testToSave = fetchSavedTest(from: test) else { return false }
        guard let jsonString = Encode.testToJsonString(test: test) else { return false }

        testToSave.dataString = jsonString
        testToSave.id = test.id
        saveContext()
        Flow.shared.settings.update(from: test)
        return true
    }

    func saveNewTest(_ test: Test) -> Bool {
        let context = persistentContainer.viewContext

        let testToSave = SavedTest(entity: SavedTest.entity(), insertInto: context)
        guard let jsonString = Encode.testToJsonString(test: test) else { return false }

        testToSave.dataString = jsonString
        testToSave.id = test.id
        saveContext()
        Flow.shared.settings.update(from: test)
        return true
    }

    func deleteTest(_ test: Test) -> Bool {
        guard let savedTest = fetchSavedTest(from: test) else { return false }
        for file in test.files {
            FilesAndPermission.deleteFile(fileName: file, test: test)
        }
        let context = persistentContainer.viewContext
        context.delete(savedTest)
        saveContext()
        return true
    }

    func fetchAllTests() -> [Test] {
        let savedTests = fetchAllSavedTests()
        var tests: [Test] = []

        for savedTest in savedTests {
            if let test = Encode.jsonStringToTest(jsonString: savedTest.dataString) {
                tests.append(test)
            }
        }
        return tests
    }

    func fetchTestFrom(oldTest: Test) -> Test? {
        let newTests = fetchAllTests()
        let newTest = newTests.first(where: { $0.id == oldTest.id })
        return newTest
    }

    func deleteAllTests() {
        let savedTests = fetchAllSavedTests()
        let context = persistentContainer.viewContext
        for element in savedTests {
            context.delete(element)
        }
        saveContext()
    }

    private func fetchAllSavedTests() -> [SavedTest] {
        var savedTests: [SavedTest] = []
        let context = persistentContainer.viewContext

        let fetchRequest = SavedTest.testFetchRequest()

        do {
            savedTests = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return savedTests
    }

    private func fetchSavedTest(from test: Test) -> SavedTest? {
        let savedTests = fetchAllSavedTests()
        let savedTest = savedTests.first(where: { $0.id == test.id })
        return savedTest
    }
}
