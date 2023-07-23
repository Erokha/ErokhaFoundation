import Foundation
import Security


public struct EFSecuritySingleValueStorage<Item: Codable> : EFSingleValueStorage {
    
    private let service = EFSecurityService<Item>()
    
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
        return "\(classname)EFSecuritySingleValueStorage"
    }
}



public struct EFSecurityMultiValueStorage<Item: Codable>: EFMultiValueStorage {
    
    private let service = EFSecurityService<Item>()
    
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
        return "\(id)\(classname)EFSecurityMultiValueStorage"
    }
    
}

struct EFSecurityService<Item: Codable> {
    
    enum EFSecurityServiceError: Error {
        case secirityError(String)
    }
    // MARK: - Internal

    func save(_ object: Item, id identifier: String) {
        guard let data = try? EFCodersProvider.defaultEncoder.encode(object) else { return }
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: identifier,
            kSecAttrAccount: identifier,
        ] as CFDictionary

        let status = SecItemAdd(query, nil)

        switch status {
        case errSecDuplicateItem:
            try? update(object: object, forIdentifier: identifier)
        case errSecSuccess:
            return
        default:
            return
        }
    }

    func restore(id identifier: String) -> Item? {
        let query = [
            kSecAttrService: identifier,
            kSecAttrAccount: identifier,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
        ] as CFDictionary

        var result: AnyObject?

        SecItemCopyMatching(query, &result)

        guard let result = result else {
            return nil
        }
        guard
            let data = result as? Data,
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
    func clear(id identifier: String) -> Item? {
        let value = restore(id: identifier)
        
        let query = [
            kSecAttrAccount: identifier,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        SecItemDelete(query)
        
        return value
    }

    // MARK: - Private

    private func update(object: Item, forIdentifier identifier: String) throws {
        let query = [
            kSecAttrService: identifier,
            kSecAttrAccount: identifier,
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary

        let data = try EFCodersProvider.defaultEncoder.encode(object)

        let attributes = [
            kSecValueData: data,
        ] as CFDictionary

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        guard status == errSecSuccess else {
            throw EFSecurityServiceError.secirityError("\(status)")
        }
    }
}
