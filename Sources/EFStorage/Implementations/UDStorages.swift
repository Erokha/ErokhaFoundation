import Foundation

public class EFUserDefaultSignleValueStorage<Item: Codable>: EFSingleValueStorage {
    
    private let userdefaults = UserDefaults.standard
    
    private var key: String {
        let classname = String(describing: Item.self)
        return "\(classname)_EFUserDefaultSignleValueStorage"
    }
    
    public func save(_ item: Item) {
        guard let data = try? EFCodersProvider.defaultEncoder.encode(item) else { return }
        userdefaults.setValue(data, forKey: key)
    }
    
    public func restore() -> Item? {
        guard
            let data = userdefaults.value(forKey: key) as? Data,
            let decoded = try? EFCodersProvider.defaultDecoder.decode(Item.self, from: data)
        else {
            return nil
        }
        
        return decoded
    }
    
    public func clear() {
        userdefaults.removeObject(forKey: key)
    }
}

public class EFUserDefaultMultiValueStorage<Item: Codable>: EFMultiValueStorage {
    
    private func key(id: String) -> String {
        let classname = String(describing: Item.self)
        return "\(id)_\(classname)_EFUserDefaultSignleValueStorage"
    }
    
    private let userdefaults = UserDefaults.standard

    public func save(_ item: Item, id: String) {
        guard let data = try? EFCodersProvider.defaultEncoder.encode(item) else { return }
        userdefaults.set(data, forKey: key(id: id))
    }

    public func restore(id: String) -> Item? {
        guard
            let data = userdefaults.value(forKey: key(id: id)) as? Data,
            let decoded = try? EFCodersProvider.defaultDecoder.decode(Item.self, from: data)
        else {
            return nil
        }
        
        return decoded
    }
    
    @discardableResult
    public func clear(id: String) -> Item? {
        let value = restore(id: id)
        userdefaults.removeObject(forKey: key(id: id))
        return value
    }
}
