//
//  SubscriptionService.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


//
//  SubscriptionService.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

/// Сервис подписки (v1: заглушка под Apphud).
/// Подписка открывает весь функционал. Токенов в первой итерации нет.
protocol SubscriptionService {
    /// Кэшированное состояние подписки (локально).
    var isSubscribed: Bool { get }

    /// Обновить состояние из источника (в v1 — локальное хранилище; дальше — Apphud).
    @discardableResult
    func refreshStatus() async throws -> Bool

    /// Покупка подписки (v1 — помечаем локально как активную).
    @discardableResult
    func purchase() async throws -> Bool

    /// Восстановить покупки (v1 — читаем локальное состояние).
    @discardableResult
    func restore() async throws -> Bool
}
