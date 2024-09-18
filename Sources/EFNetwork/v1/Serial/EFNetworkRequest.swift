import Foundation

public final class EFNetworkRequest {
    
    // MARK: - Private types
    
    private enum State {
        case pending
        case finishedWithSuccess(data: Data, urlResponse: HTTPURLResponse)
        case finishedWithFailure
    }
    
    private class StatedHandler {
        let handler: any NetworkHandlerProtocol
        var notified: Bool
        
        init(handler: any NetworkHandlerProtocol) {
            self.handler = handler
            self.notified = false
        }
    }
    
    // MARK: - Private feids
    
    private let session: URLSession
    private let queue = DispatchQueue(label: "EFNetworkRequest.queue")
    private var handlers: [StatedHandler]
    private var fallback: (() -> Void)?
    private var state: State {
        didSet {
            handleDidUpdateState(oldValue: oldValue)
        }
    }
    
    // MARK: - Init
    
    init(session: URLSession, request: URLRequest?) {
        self.session = session
        handlers = []
        fallback = nil
        self.state = .pending
        queue.async { [weak self] in
            guard let self = self else { return }
            Task {
                guard
                    let request = request,
                    let (data, urlResponse) = try? await self.session.data(for: request),
                    let httpUrlResponse = urlResponse as? HTTPURLResponse
                else {
                    self.queue.async {
                        self.state = .finishedWithFailure
                    }
                    return
                }
                
                self.queue.async {
                    self.state = .finishedWithSuccess(data: data, urlResponse: httpUrlResponse)
                }
            }
        }
    }
    
    // MARK: - Public methods
    
    public func handle<T: Decodable>(
        statusCode: Int,
        of type: T.Type = T.self,
        completion: @escaping (T) -> Void
    ) -> EFNetworkRequest {
        queue.async {
            let handler = StatedHandler(
                handler: EFNetworkHanlder(statusCode: statusCode, completion: completion)
            )
            switch self.state {
            case .pending:
                self.handlers.append(handler)
            case .finishedWithSuccess(let data, let urlResponse):
                self.notifyHandlerIfNeeded(handler: handler, data: data, urlResponse: urlResponse)
            case .finishedWithFailure:
                break
            }
        }
        return self
    }
    
    public func handle<T: Decodable>(
        statusCode: Int,
        of type: T.Type = T.self,
        completion: @escaping (T) async -> Void
    ) -> EFNetworkRequest {
        return self.handle(
            statusCode: statusCode,
            of: type,
            completion: { result in
                Task {
                    await completion(result)
                }
            }
        )
    }
    
    @discardableResult
    public func fallback(
        completion: @escaping () -> Void
    ) -> EFNetworkRequest {
        queue.async {
            self.fallback = completion
        }
        return self
    }
    
    @discardableResult
    public func fallback(
        completion: @escaping () async -> Void
    ) -> EFNetworkRequest {
        return self.fallback {
            Task {
                await completion()
            }
        }
    }
    
    // MARK: - Private methods
    
    private func handleDidUpdateState(oldValue: State) {
        queue.async {
            switch self.state {
            case .pending:
                break
            case .finishedWithSuccess(let data, let urlResponse):
                if self.noityfyAllHandlers(data: data, urlResponse: urlResponse) == false {
                    self.fallback?()
                }
            case .finishedWithFailure:
                for handler in self.handlers {
                    handler.notified = true
                }
                self.fallback?()
            }
        }
    }
    
    private func noityfyAllHandlers(
        data: Data,
        urlResponse: HTTPURLResponse
    ) -> Bool {
        var anyHandlerResponsed = false
        for handler in self.handlers {
            let handled = self.notifyHandlerIfNeeded(handler: handler, data: data, urlResponse: urlResponse)
            if anyHandlerResponsed == false {
                anyHandlerResponsed = handled
            }
        }
        return anyHandlerResponsed
    }
    
    @discardableResult
    private func notifyHandlerIfNeeded(
        handler: StatedHandler,
        data: Data,
        urlResponse: HTTPURLResponse
    ) -> Bool {
        defer {
            handler.notified = true
        }
        if !handler.notified && handler.handler.statusCode == urlResponse.statusCode {
            return handler.handler.decode(data: data)
        } else {
            return false
        }
        
    }
    
    
}

public extension Data {
    var debugJSON: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
