//
//  SubscriptionServiceStub.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//



import Foundation

/// Заглушка до интеграции Apphud/StoreKit 2.
/// Успешно "покупает" или "восстанавливает" и включает premium.
final class SubscriptionServiceStub: SubscriptionService {

    private var store: PremiumStore

    init(store: PremiumStore) {
        self.store = store
    }

    func purchase(plan: SubscriptionPlan) async throws {
        // Микрозадержка, имитация сети
        try await Task.sleep(nanoseconds: 400_000_000)
        store.isPremium = true
    }

    func restore() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        // В заглушке считаем, что покупки были — включаем premium
        store.isPremium = true
    }
}
