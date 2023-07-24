import Foundation

private class AbstractEFSingleValueStorage<Item: Codable>: EFSingleValueStorage {
    
    func save(_ item: Item) {
        fatalError("should never be called")
    }
    
    func restore() -> Item? {
        fatalError("should never be called")
    }
    
    func clear() {
        fatalError("should never be called")
    }
}

private class ConcrateEFSingleValueStorageBox<
    Storage: EFSingleValueStorage
>: AbstractEFSingleValueStorage<Storage.Item> where Storage.Item: Codable {
    let concrateStorage: Storage
    
    init(concrateStorage: Storage) {
        self.concrateStorage = concrateStorage
    }
    
    override func save(_ item: Storage.Item) {
        concrateStorage.save(item)
    }
    
    override func restore() -> Storage.Item? {
        concrateStorage.restore()
    }
    
    override func clear() {
        concrateStorage.clear()
    }
}

public class AnyEFSingleValueStorage<Item: Codable>: EFSingleValueStorage {
    
    private let box: AbstractEFSingleValueStorage<Item>
    
    public init<Storage: EFSingleValueStorage>(_ storage: Storage) where Storage.Item == Item {
        self.box = ConcrateEFSingleValueStorageBox(concrateStorage: storage)
    }
    
    public func save(_ item: Item) {
        box.save(item)
    }
    
    public func restore() -> Item? {
        box.restore()
    }
    
    public func clear() {
        box.clear()
    }
    
}
