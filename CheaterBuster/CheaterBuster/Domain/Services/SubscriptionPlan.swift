//
//  SubscriptionPlan.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import Foundation

public enum SubscriptionPlan: Equatable {
    case monthly
    case yearly
}

public protocol SubscriptionService {
    /// Покупка выбранного плана (заглушка Apphud на D2).
    func purchase(plan: SubscriptionPlan) async throws

    /// Восстановление покупок.
    func restore() async throws
}
