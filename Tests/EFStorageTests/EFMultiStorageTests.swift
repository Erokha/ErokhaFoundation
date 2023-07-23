import XCTest
@testable import EFStorage

final class EFMultiStorageTests: XCTestCase {
    private let factory = EFStorageFactory<EFStorageTestStruct>.multiValueStorage
    
    var testItem1 = EFStorageTestStruct(name: "Erokha", age: 23)
    var testId1 = "id1"
    
    var testItem2 = EFStorageTestStruct(name: "Erokha_duplicate", age: 123)
    var testId2 = "id2"
    
    func testUD() throws {
        try testSave(storage: factory.userDefaults)
        try testClear(storage: factory.userDefaults)
        try testOverride(storage: factory.userDefaults)
    }
    
    func testFile() throws {
        try testSave(storage: factory.file)
        try testClear(storage: factory.file)
        try testOverride(storage: factory.file)
    }
    
    // MARK: - Generic
    
    func testSave<Storage: EFMultiValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        storage.clear(id: testId1)
        storage.clear(id: testId2)
        
        storage.save(testItem1, id: testId1)
        storage.save(testItem2, id: testId2)
        
        XCTAssertEqual(storage.restore(id: testId1), testItem1)
        XCTAssertEqual(storage.restore(id: testId2), testItem2)
    }
    
    func testClear<Storage: EFMultiValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        storage.clear(id: testId1)
        
        storage.save(testItem1, id: testId1)
        XCTAssertEqual(storage.restore(id: testId1), testItem1)
        
        storage.clear(id: testId1)
        XCTAssertEqual(storage.restore(id: testId1), nil)
    }
    
    func testOverride<Storage: EFMultiValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        storage.clear(id: testId1)
        
        storage.save(testItem1, id: testId1)
        XCTAssertEqual(storage.restore(id: testId1), testItem1)
        
        storage.save(testItem2, id: testId1)
        XCTAssertEqual(storage.restore(id: testId1), testItem2)
    }
    
    
}
