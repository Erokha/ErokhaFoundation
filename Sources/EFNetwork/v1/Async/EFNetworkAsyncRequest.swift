import Foundation

public struct EFNetworkAsyncRequest {
    
    // MARK: - Private feids
    
    private let session: URLSession
    private let request: URLRequest?
    private let interceptors: [EFResponseInterceptor]
    
    // MARK: - Init
    
    init(
        session: URLSession,
        request: URLRequest?,
        interceptors: [EFResponseInterceptor]
    ) {
        self.session = session
        self.request = request
        self.interceptors = interceptors
    }
    
    func response<ReturnType>(
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        guard
            let request = request,
            let (data, urlResponse) = try? await self.session.data(for: request)
        else {
            return intercept(with: nil) ?? EFNetworkAsyncResponse(response: nil, data: nil)
        }
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            return intercept(with: nil) ?? EFNetworkAsyncResponse(response: nil, data: data)
        }
        
        return intercept(with: httpUrlResponse) ?? EFNetworkAsyncResponse(response: httpUrlResponse, data: data)
    }
    
    private func intercept<ReturnType>(
        with response: HTTPURLResponse?,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) -> EFNetworkAsyncResponse<ReturnType>? {
        for interceptor in interceptors {
            if !interceptor.intercept(response: response) {
                return EFNetworkAsyncResponse(response: nil, data: nil)
            }
        }
        return nil
    }

}
