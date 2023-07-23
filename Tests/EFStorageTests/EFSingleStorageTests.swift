import XCTest
@testable import EFStorage

struct EFStorageTestStruct: Codable, Equatable {
    let name: String
    let age: Int
}

final class EFSingleStorageTests: XCTestCase {
    private let factory = EFStorageFactory<EFStorageTestStruct>.singleValueStorage
    
    var testItem1 = EFStorageTestStruct(name: "Erokha", age: 23)
    var testItem2 = EFStorageTestStruct(name: "Erokha_duplicate", age: 123)
    
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
    
    func testSave<Storage: EFSingleValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        storage.clear()
        storage.save(testItem1)
        XCTAssertEqual(storage.restore(), testItem1)
    }
    
    func testClear<Storage: EFSingleValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        // saving
        storage.clear()
        storage.save(testItem1)
        XCTAssertEqual(storage.restore(), testItem1)
        
        // removing
        storage.clear()
        XCTAssertEqual(storage.restore(), nil)
    }
    
    func testOverride<Storage: EFSingleValueStorage>(storage: Storage) throws
    where Storage.Item == EFStorageTestStruct {
        // saving
        storage.clear()
        storage.save(testItem1)
        XCTAssertEqual(storage.restore(), testItem1)
        
        // overriding
        storage.save(testItem2)
        XCTAssertEqual(storage.restore(), testItem2)
    }
    
    
}
