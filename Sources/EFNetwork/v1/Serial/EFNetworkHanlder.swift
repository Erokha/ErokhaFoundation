import Foundation

protocol NetworkHandlerProtocol {
    associatedtype DecodableType: Decodable
    
    var statusCode: Int { get }
    func decode(data: Data) -> Bool
}

struct EFNetworkHanlder<ValueType: Decodable>: NetworkHandlerProtocol {
    typealias DecodableType = ValueType
    
    let statusCode: Int
    let completion: (ValueType) -> Void
    
    func decode(data: Data) -> Bool {
        guard
            let decoded = try? JSONDecoder().decode(ValueType.self, from: data)
        else {
            print("Unable to decode. Info:")
            print("type: \(type(of: ValueType.self))")
            return false
        }
        completion(decoded)
        return true
    }
}
