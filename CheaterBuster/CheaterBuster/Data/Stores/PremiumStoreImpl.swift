//
//  PremiumStoreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import Foundation

final class PremiumStoreImpl: PremiumStore {
    private let key = "cb.premium.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isPremium: Bool {
        get {
            // дефолт — false
            (defaults.object(forKey: key) as? Bool) ?? false
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
}
