import Foundation

public struct EFStorageFactory<Item: Codable> {
    
    public struct EFSingleValueStorageFactory<SignleValueItem: Codable> {
        public let userDefaults = EFUserDefaultSignleValueStorage<SignleValueItem>()
        public let file = EFFileBasedSingleValueStorage<SignleValueItem>()
        public let security = EFSecuritySingleValueStorage<SignleValueItem>()
    }
    
    public struct EFMultiValueStorageFactory<MultiValueItem: Codable> {
        public let userDefaults = EFUserDefaultMultiValueStorage<MultiValueItem>()
        public let file = EFFileBasedMultiValueStorage<MultiValueItem>()
        public let security = EFSecurityMultiValueStorage<MultiValueItem>()
    }
    
    public static var singleValueStorage: EFSingleValueStorageFactory<Item> {
        EFSingleValueStorageFactory<Item>()
    }
    
    public static var multiValueStorage: EFMultiValueStorageFactory<Item> {
        EFMultiValueStorageFactory<Item>()
    }
}
