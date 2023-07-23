import Foundation
import Combine

public final class EFNetworkAsyncResponse<ReturnType> {
    
    public struct FallbackData {
        public let response: HTTPURLResponse?
        public let data: Data?
    }
    
    // MARK: - Private feids
    
    private let response: HTTPURLResponse?
    private let data: Data?
    private var result: ReturnType?
    
    private lazy var fallbackData = FallbackData(response: response, data: data)
    // MARK: - Init
    
    init(response: HTTPURLResponse?, data: Data?) {
        self.response = response
        self.data = data
        self.result = nil
    }
    
    // MARK: - Handlers
    
    public func handle<T: Decodable>(
        statusCode: Int,
        of type: T.Type = T.self,
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping (T) -> ReturnType
    ) -> EFNetworkAsyncResponse {
        guard
            let data = data,
            let response = response,
            response.statusCode == statusCode,
            result == nil
        else { return self }
        
        let asyncHandler = EFNetworkAsyncResponseSerialHandler<T, ReturnType>.init(completion: completion)
        result = asyncHandler.decode(data: data)
        
        return self
    }
    
    public func handle<T: Decodable>(
        statusCode: Int,
        of type: T.Type = T.self,
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping (T) async -> ReturnType
    ) async -> EFNetworkAsyncResponse {
        guard
            let data = data,
            let response = response,
            response.statusCode == statusCode,
            result == nil
        else { return self }
        
        let asyncHandler = EFNetworkAsyncResponseAsyncHandler<T, ReturnType>.init(completion: completion)
        result = await asyncHandler.decode(data: data)
        
        return self
    }
    
    public func handleCode(
        _ statusCode: Int,
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping () async -> ReturnType
    ) async -> EFNetworkAsyncResponse {
        guard
            let response = response,
            response.statusCode == statusCode,
            result == nil
        else { return self }
        
        let asyncHandler = EFNetworkAsyncResponseAsyncCodeOnlyHandler(completion: completion)
        result = await asyncHandler.handle()
        
        return self
    }
    
    
    public func fallback(
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping () -> ReturnType
    ) -> ReturnType {
        guard let result = result else {
            return completion()
        }
        return result
    }
    
    public func fallback(
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping () async -> ReturnType
    ) async -> ReturnType{
        guard let result = result else {
            return await completion()
        }
        return result
    }
    
    public func fallbackDetail(
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping (FallbackData) -> ReturnType
    ) -> ReturnType {
        guard let result = result else {
            return completion(fallbackData)
        }
        return result
    }
    
    public func fallbackDetail(
        shouldReturn: ReturnType.Type = ReturnType.self,
        completion: @escaping (FallbackData) async -> ReturnType
    ) async -> ReturnType{
        guard let result = result else {
            return await completion(fallbackData)
        }
        return result
    }
    
}
