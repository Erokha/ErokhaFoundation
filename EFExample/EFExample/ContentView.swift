//
//  ContentView.swift
//  EFExample
//
//  Created by Nikita Erokhin on 1/31/25.
//

import SwiftUI
import EFNetwork

@MainActor
final class ContentStore: ObservableObject {
    
    private struct CatFactDTO: Decodable {
        let fact: String
    }
    
    private let manager = EFNetworkManager.default
    
    enum ViewState: Equatable {
        case text(String)
        case error(String)
        case loading
        
        var isButtonDisabled: Bool {
            self == .loading
        }
    }
    
    @Published
    var viewState: ViewState = .text("Make your first requst")
    
    func makeRequest() {
        guard viewState != .loading else { return }
        viewState = .loading
        Task { @MainActor in
            let fact = await requestCatFact()
            viewState = .text("Fact: \(fact)")
        }
    }
    
    private func requestCatFact() async -> String {
        await manager
            .getAsync(
                url: "https://catfact.ninja/fact"
            )
            .handle(statusCode: 200, of: CatFactDTO.self) { response in
                return response.fact
            }
            .fallback {
                return "Unknown error"
            }
     }
    
}

struct ContentView: View {
    
    @ObservedObject
    var store = ContentStore()
    
    var body: some View {
        VStack {
            text
            Spacer()
            Spacer()
            Button("Make reuqest") {
                store.makeRequest()
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(store.viewState.isButtonDisabled)
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var text: some View {
        switch store.viewState {
        case .text(let string):
            Text(string)
        case .error(let string):
            Text(string).foregroundStyle(.red)
        case .loading:
            ProgressView()
        }
    }
}

#Preview {
    ContentView()
}
