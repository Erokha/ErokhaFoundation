//
//  File.swift
//  
//
//  Created by Nikita Erokhin on 7/23/23.
//

import Foundation

public struct EFFileBasedSingleValueStorage<Item: Codable> : EFSingleValueStorage {
    private var key: String {
        let classname = String(describing: Item.self)
        return "\(classname)_EFFileBasedSingleValueStorage"
    }
    
    public func save(_ item: Item) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        do {
            try data.write(to: fileURL, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    public func restore() -> Item? {
        guard
            let data = FileManager.default.contents(atPath: fileURL.path)
        else {
            return nil
        }

        guard
            let decoded = try? JSONDecoder().decode(
                Item.self,
                from: data
            )
        else {
            return nil
        }

        return decoded
    }
    
    public func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private var fileURL: URL {
        let path = try! FileManager.default.url(
            for: .applicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("\(key)")
        return path
    }
}



public struct EFFileBasedMultiValueStorage<Item: Codable> : EFMultiValueStorage {
    
    public func save(_ item: Item, id: String) {
        guard let data = try? JSONEncoder().encode(item) else { return }
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
            let decoded = try? JSONDecoder().decode(
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
    
    private func key(id: String) -> String {
        let classname = String(describing: Item.self)
        return "\(id)_\(classname)_EFFileBasedMultiValueStorage"
    }
    
    private func fileURL(id: String) -> URL {
        let path = try! FileManager.default.url(
            for: .applicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(key(id: id))
        return path
    }
}
