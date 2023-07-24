import Foundation

private class AbstractEFMultiValueStorage<Item: Codable>: EFMultiValueStorage {
    
    func save(_ item: Item, id: String) {
        fatalError("Should never be called")
    }
    
    func restore(id: String) -> Item? {
        fatalError("Should never be called")
    }
    
    func clear(id: String) -> Item? {
        fatalError("Should never be called")
    }
    
}

private class ConcrateEFMultiValueStorageBox<
    Storage: EFMultiValueStorage
> : AbstractEFMultiValueStorage<Storage.Item> where Storage.Item: Codable {
    
    let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    override func save(_ item: Storage.Item, id: String) {
        storage.save(item, id: id)
    }
    
    override func restore(id: String) -> Storage.Item? {
        storage.restore(id: id)
    }
    
    override func clear(id: String) -> Storage.Item? {
        storage.clear(id: id)
    }
    
}

public class AnyEFMultiValueStorage<Item: Codable>: EFMultiValueStorage {
    
    private let box: AbstractEFMultiValueStorage<Item>
    
    public init<Storage: EFMultiValueStorage>(_ storage: Storage) where Storage.Item == Item {
        self.box = ConcrateEFMultiValueStorageBox(storage: storage)
    }
    
    public func save(_ item: Item, id: String) {
        box.save(item, id: id)
    }
    
    public func restore(id: String) -> Item? {
        box.restore(id: id)
    }
    
    public func clear(id: String) -> Item? {
        box.clear(id: id)
    }
    
}
