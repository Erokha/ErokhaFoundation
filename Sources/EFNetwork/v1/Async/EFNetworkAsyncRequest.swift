import Foundation

public struct EFNetworkAsyncRequest {
    
    // MARK: - Private feids
    
    private let session: URLSession
    private let request: URLRequest?
    private let interceptors: [EFResponseInterceptor]
    private let madeManager: EFNetworkManager
    
    // MARK: - Init
    
    init(
        session: URLSession,
        request: URLRequest?,
        interceptors: [EFResponseInterceptor],
        madeManager: EFNetworkManager
    ) {
        self.session = session
        self.request = request
        self.interceptors = interceptors
        self.madeManager = madeManager
    }
    
    func response<ReturnType>(
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        guard
            let request = request,
            let (data, urlResponse) = try? await self.session.data(for: request)
        else {
            return await intercept(
                with: EFNetworkAsyncResponse(
                    response: nil,
                    data: nil
                )
            )
        }
        
        return await intercept(
            with: EFNetworkAsyncResponse(
                response: urlResponse as? HTTPURLResponse,
                data: data
            )
        )
    }
    
    private func intercept<ReturnType>(
        with response: EFNetworkAsyncResponse<ReturnType>,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        guard let request else { return response }
        var interecpted = response
        for interceptor in interceptors {
            interecpted = await interceptor.intercept(
                manager: madeManager,
                request: request,
                response: interecpted
            )
        }
        return interecpted
    }

}
