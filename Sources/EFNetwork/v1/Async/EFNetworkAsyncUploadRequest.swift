import Foundation

public struct EFNetworkAsyncUploadRequest {
    
    
    private let session: URLSession
    private let request: URLRequest?
    private let data: Data
    
    // MARK: - Init
    
    init(session: URLSession, request: URLRequest?, data: Data) {
        self.session = session
        self.request = request
        self.data = data
    }
    
    func response<ReturnType>(
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        guard
            let request = request,
            let (data, urlResponse) = try? await self.session.upload(for: request, from: data)
        else {
            return EFNetworkAsyncResponse(response: nil, data: nil)
        }
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            return EFNetworkAsyncResponse(response: nil, data: data)
        }
        
        return EFNetworkAsyncResponse(response: httpUrlResponse, data: data)
    }
    
}
