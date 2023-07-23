//
//  File.swift
//  
//
//  Created by Nikita Erokhin on 5/10/23.
//

import Foundation
import Combine

public func onMainActor(closure: @escaping () -> Void) {
    Task {
        await MainActor.run { closure() }
    }
}
