import Foundation


public struct EFStorageFactory<Item: Codable> {
    
    public struct EFSingleValueStorageFactory<Item: Codable> {
        public let userDefaults = EFUserDefaultSignleValueStorage<Item>()
        public let file = EFFileBasedSingleValueStorage<Item>()
    }
    
    public struct EFMultiValueStorageFactory<Item: Codable> {
        public let userDefaults = EFUserDefaultMultiValueStorage<Item>()
        public let file = EFFileBasedMultiValueStorage<Item>()
    }
    
    public static var singleValueStorage: EFSingleValueStorageFactory<Item> {
        EFSingleValueStorageFactory<Item>()
    }
    
    public static var multiValueStorage: EFMultiValueStorageFactory<Item> {
        EFMultiValueStorageFactory<Item>()
    }
}
