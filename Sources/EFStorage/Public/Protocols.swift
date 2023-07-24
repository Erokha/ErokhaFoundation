import Foundation

/// Use `AnyEFSingleValueStorage` for type-erasure
public protocol EFSingleValueStorage {
    associatedtype Item = Codable

    func save(_ item: Item)
    func restore() -> Item?
    func clear()
}

/// Use `AnyEFSingleValueStorage` for type-erasure
public protocol EFMultiValueStorage {
    associatedtype Item = Codable

    func save(_ item: Item, id: String)
    func restore(id: String) -> Item?
    @discardableResult
    func clear(id: String) -> Item?
}
