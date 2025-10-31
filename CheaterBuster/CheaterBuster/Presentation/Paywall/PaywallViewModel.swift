//
//  PaywallViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {

    // MARK: - Output
    @Published var selected: SubscriptionPlan = .yearly
    @Published private(set) var isProcessing: Bool = false
    @Published var errorText: String?
    @Published private(set) var didFinish: Bool = false

    // MARK: - Deps
    private let subscription: SubscriptionService

    init(subscription: SubscriptionService) {
        self.subscription = subscription
    }

    // MARK: - Intent
    func buy() {
        Task {
            await performPurchase()
        }
    }

    func restore() {
        Task {
            await performRestore()
        }
    }

    // MARK: - Added
    // MARK: - Private

    private func performPurchase() async {
        isProcessing = true
        errorText = nil
        do {
            try await subscription.purchase(plan: selected)
            didFinish = true
        } catch {
            errorText = error.localizedDescription
        }
        isProcessing = false
    }

    private func performRestore() async {
        isProcessing = true
        errorText = nil
        do {
            try await subscription.restore()
            didFinish = true
        } catch {
            errorText = error.localizedDescription
        }
        isProcessing = false
    }
}
