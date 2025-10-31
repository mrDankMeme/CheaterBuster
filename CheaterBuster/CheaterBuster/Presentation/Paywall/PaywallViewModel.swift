//
//  PaywallViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


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
    // MARK: - Types

    struct Plan: Identifiable, Equatable {
        enum Period { case monthly, yearly }
        let id: String
        let title: String
        let priceText: String
        let subline: String?
        let period: Period
        let isRecommended: Bool
    }

    // MARK: - Output
    @Published private(set) var plans: [Plan] = []
    @Published var selectedPlanID: String?
    @Published private(set) var isLoading = false
    @Published var errorText: String?

    // MARK: - Deps
    private let subscription: SubscriptionService

    // MARK: - Init
    init(subscription: SubscriptionService) {
        self.subscription = subscription
        self.plans = Self.defaultPlans()
        self.selectedPlanID = plans.last?.id // выделяем годовой
    }

    // MARK: - Actions

    func purchaseSelected() {
        guard let _ = selectedPlanID else { return }
        // В v1 оба плана включают одинаковый доступ — различается только текст.
        Task {
            isLoading = true
            errorText = nil
            do {
                _ = try await subscription.purchase()
            } catch {
                errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    func restore() {
        Task {
            isLoading = true
            errorText = nil
            do {
                _ = try await subscription.restore()
            } catch {
                errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Helpers

    private static func defaultPlans() -> [Plan] {
        [
            .init(
                id: "monthly.stub", // заглушки — будут заменены Apphud product ids
                title: "$9.99 / month",
                priceText: "$9.99 / month",
                subline: nil,
                period: .monthly,
                isRecommended: false
            ),
            .init(
                id: "yearly.stub",
                title: "$69.99 / year",
                priceText: "$69.99 / year",
                subline: "$5.83 / month billed annually",
                period: .yearly,
                isRecommended: true
            )
        ]
    }
}
