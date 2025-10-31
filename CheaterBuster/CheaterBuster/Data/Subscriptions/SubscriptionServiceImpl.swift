//
//  SubscriptionServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


//
//  SubscriptionServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

/// Реализация заглушки подписки для v1.
/// Сейчас: локальный флаг в UserDefaults. Далее заменим на Apphud SDK.
final class SubscriptionServiceImpl: SubscriptionService {
    private let defaults: UserDefaults
    private let key = "cb.subscribed.v1"

    private(set) var isSubscribed: Bool

    // MARK: - Init
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isSubscribed = defaults.bool(forKey: key)
    }

    // MARK: - SubscriptionService

    @discardableResult
    func refreshStatus() async throws -> Bool {
        // V1: читаем локально. Позже — запрос в Apphud.
        isSubscribed = defaults.bool(forKey: key)
        return isSubscribed
    }

    @discardableResult
    func purchase() async throws -> Bool {
        // V1: помечаем локально как куплено.
        isSubscribed = true
        defaults.set(true, forKey: key)
        return true
    }

    @discardableResult
    func restore() async throws -> Bool {
        // V1: читаем локально. Позже — Apphud.restore().
        isSubscribed = defaults.bool(forKey: key)
        return isSubscribed
    }
}
