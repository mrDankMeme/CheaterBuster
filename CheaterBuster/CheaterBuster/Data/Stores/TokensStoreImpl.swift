//
//  TokensStoreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import Foundation

final class TokensStoreImpl: TokensStore {
    private let key = "cb.tokens.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var tokens: Int {
        get { defaults.object(forKey: key) as? Int ?? 0 }
        set { defaults.set(newValue, forKey: key) }
    }
}
