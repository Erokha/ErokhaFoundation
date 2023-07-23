import Foundation

public protocol EFRequestInterceptor {
    func intercept(request: URLRequest) -> URLRequest
}

public protocol EFResponseInterceptor {
    func intercept(response: HTTPURLResponse?) -> Bool
}

public struct EFNetworkManager {
    
    public static let `default` = EFNetworkManager(
        session: .shared,
        requestInterceptors: [],
        responseInterceptors: []
    )
    
    private var requestInterceptors: [EFRequestInterceptor]
    private var responseInterceptors: [EFResponseInterceptor]
    private let session: URLSession
    
    public init(
        session: URLSession,
        requestInterceptors: [EFRequestInterceptor],
        responseInterceptors: [EFResponseInterceptor]
    ) {
        self.session = session
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
    }

    // MARK: - Async requests
    
    public func getAsync<ReturnType>(
        url: String,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        return await asyncRequest(url: url, method: "Get", body: String?.none)
    }
    
    public func postAsync<Body: Encodable, ReturnType>(
        url: String,
        body: Body,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        return await asyncRequest(url: url, method: "POST", body: body)
    }
    
    public func postAsync<ReturnType>(
        url: String,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        return await asyncRequest(url: url, method: "POST", body: String?.none)
    }
    
    // MARK: - Upload tasks
    
    public func upload<ReturnType>(data: Data, url: String) async -> EFNetworkAsyncResponse<ReturnType> {
        let baseRequest = prepareUploadRequest(url: url)
        let request = EFNetworkAsyncUploadRequest(session: session, request: baseRequest, data: data)
        return await request.response()
    }
    
    // MARK: - Private methods
    
    private func request<Body: Encodable>(url: String, method: String, body: Body?) -> EFNetworkRequest {
        let request = prepareRequest(url: url, method: method, body: body)
        return EFNetworkRequest(session: session, request: request)
    }
    
    private func asyncRequest<Body: Encodable, ReturnType>(
        url: String,
        method: String,
        body: Body?,
        shouldMapResultTo: ReturnType.Type = ReturnType.self
    ) async -> EFNetworkAsyncResponse<ReturnType> {
        let urlRequest = prepareRequest(url: url, method: method, body: body)
        let asyncRequest = EFNetworkAsyncRequest(
            session: session,
            request: urlRequest,
            interceptors: responseInterceptors
        )
        return await asyncRequest.response()
    }
    
    private func prepareRequest<Body: Encodable>(url: String, method: String, body: Body?) -> URLRequest? {
        let encodedBody = body.flatMap { try? JSONEncoder().encode($0) }
        var request = URLRequest?.none
        if let url = URL(string: url) {
            request = URLRequest(url: url)
        }
        request?.httpMethod = method
        request?.httpBody = encodedBody
        if let notOptinalrequest = request {
            for requestInterceptor in requestInterceptors {
                request = requestInterceptor.intercept(request: notOptinalrequest)
            }
        }
        return request
    }
    
    private func prepareUploadRequest(url: String) -> URLRequest? {
        var request = URLRequest?.none
        if let url = URL(string: url) {
            request = URLRequest(url: url)
        }
        request?.httpMethod = "PUT"
        if let notOptinalrequest = request {
            for requestInterceptor in requestInterceptors {
                request = requestInterceptor.intercept(request: notOptinalrequest)
            }
        }
        return request
    }
    
}
