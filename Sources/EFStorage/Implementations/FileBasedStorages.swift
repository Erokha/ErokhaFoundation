import Foundation

public struct EFFileBasedSingleValueStorage<Item: Codable> : EFSingleValueStorage {
    
    private let service = EFFileBasedService<Item>()
    
    public func save(_ item: Item) {
        service.save(item, id: key)
    }
    
    public func restore() -> Item? {
        service.restore(id: key)
    }
    
    public func clear() {
        service.clear(id: key)
    }
    
    private var key: String {
        let classname = String(describing: Item.self)
        return "\(classname)_EFFileBasedSingleValueStorage"
    }
}

public struct EFFileBasedMultiValueStorage<Item: Codable>: EFMultiValueStorage {
    
    private let service = EFFileBasedService<Item>()
    
    public func save(_ item: Item, id: String) {
        service.save(item, id: key(id: id))
    }
    
    public func restore(id: String) -> Item? {
        service.restore(id: key(id: id))
    }
    
    public func clear(id: String) -> Item? {
        service.clear(id: key(id: id))
    }
    
    private func key(id: String) -> String {
        let classname = String(describing: Item.self)
        return "\(id)_\(classname)_EFFileBasedMultiValueStorage"
    }
    
}

struct EFFileBasedService<Item: Codable> {
    
    public func save(_ item: Item, id: String) {
        guard let data = try? EFCodersProvider.defaultEncoder.encode(item) else { return }
        do {
            try data.write(to: fileURL(id: id), options: [])
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    public func restore(id: String) -> Item? {
        guard
            let data = FileManager.default.contents(atPath: fileURL(id: id).path)
        else {
            return nil
        }

        guard
            let decoded = try? EFCodersProvider.defaultDecoder.decode(
                Item.self,
                from: data
            )
        else {
            return nil
        }

        return decoded
    }
    
    @discardableResult
    public func clear(id: String) -> Item? {
        let value = restore(id: id)
        try? FileManager.default.removeItem(at: fileURL(id: id))
        return value
    }
    
    private func fileURL(id: String) -> URL {
        let path = try! FileManager.default.url(
            for: .applicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(id)
        return path
    }
    
}
