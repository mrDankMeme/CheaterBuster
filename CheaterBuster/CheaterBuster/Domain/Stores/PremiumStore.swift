//
//  PremiumStore.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

public protocol PremiumStore {
    /// Флаг подписки. В первой итерации — просто boolean.
    var isPremium: Bool { get set }
}
