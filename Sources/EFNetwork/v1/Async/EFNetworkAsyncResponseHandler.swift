import Foundation

struct EFNetworkAsyncResponseSerialHandler<T: Decodable, ReturnType> {
    
    var completion: (T) -> ReturnType
    
    func decode(data: Data) -> ReturnType? {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return completion(decoded)
        } catch {
            print("⚠️⚠️⚠️")
            print("Unable to decode. Info:")
            print("type: \(type(of: T.self))")
            print("error: \(error)")
            print("localizedDescription: \(error.localizedDescription)")
            print("⚠️⚠️⚠️")
            return nil
        }
    }
    
}

struct EFNetworkAsyncResponseAsyncHandler<T: Decodable, ReturnType> {
    
    var completion: (T) async -> ReturnType
    
    func decode(data: Data) async -> ReturnType? {
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return await completion(decoded)
        } catch {
            print("⚠️⚠️⚠️")
            print("Unable to decode. Info:")
            print("type: \(type(of: T.self))")
            print("error: \(error)")
            print("localizedDescription: \(error.localizedDescription)")
            print("⚠️⚠️⚠️")
            return nil
        }
    }
    
}

struct EFNetworkAsyncResponseAsyncCodeOnlyHandler<ReturnType> {
    
    var completion: () async -> ReturnType
    
    func handle() async -> ReturnType? {
        return await completion()
    }
    
}
