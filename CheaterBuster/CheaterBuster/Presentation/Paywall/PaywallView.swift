//
//  PaywallView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


//
//  PaywallView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct PaywallView: View {
    @ObservedObject var vm: PaywallViewModel

    /// Вызывается, если покупка/restore успешны (чтобы закрыть paywall).
    var onUnlock: (() -> Void)?

    /// Вызывается при закрытии крестиком.
    var onClose: (() -> Void)?

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: Tokens.Spacing.x16) {
                        hero
                        title
                        featureCard
                        pageIndicator

                        ForEach(vm.plans) { plan in
                            PlanRow(
                                title: plan.title,
                                subline: plan.subline,
                                isSelected: vm.selectedPlanID == plan.id,
                                isRecommended: plan.isRecommended
                            )
                            .onTapGesture { vm.selectedPlanID = plan.id }
                            .padding(.horizontal, Tokens.Spacing.x16)
                        }

                        Text("Cancel at any time")
                            .font(Tokens.Font.captionRegular)
                            .foregroundStyle(Tokens.Color.textSecondary)
                            .padding(.top, Tokens.Spacing.x8)

                        continueButton
                            .padding(.horizontal, Tokens.Spacing.x16)
                            .padding(.top, Tokens.Spacing.x16)

                        linksBar
                            .padding(.horizontal, Tokens.Spacing.x16)
                            .padding(.top, Tokens.Spacing.x16)

                        Spacer(minLength: Tokens.Spacing.x16)
                    }
                    .padding(.bottom, Tokens.Spacing.x24)
                }
            }

            if vm.isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.4)
            }
        }
        .onReceive(vm.$isLoading.dropFirst()) { _ in
            // если только что отработала purchase/restore и подписка стала активной — закрываем
            // (в v1 заглушке purchase всегда успешен → просто закрываем в конце)
            if !vm.isLoading, vm.errorText == nil {
                onUnlock?()
            }
        }
        .alert("Error", isPresented: Binding(get: { vm.errorText != nil }, set: { _ in vm.errorText = nil })) {
            Button("OK", role: .cancel) { vm.errorText = nil }
        } message: {
            Text(vm.errorText ?? "")
        }
    }

    // MARK: - Pieces

    private var header: some View {
        HStack {
            Spacer()
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(12)
                    .background(
                        Tokens.Color.surfaceCard,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)
        }
    }

    private var hero: some View {
        // В макете — иллюстрация головы. Тут используем системную заглушку.
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Tokens.Color.accent.opacity(0.6))
            .frame(height: 180)
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x8)
    }

    private var title: some View {
        HStack {
            Text("Unlock the full power of AI")
                .font(Tokens.Font.title)
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x16)
    }

    private var featureCard: some View {
        HStack(alignment: .top, spacing: Tokens.Spacing.x12) {
            Image(systemName: "heart.text.square")
                .foregroundStyle(Tokens.Color.accent)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("Check your partner")
                    .font(Tokens.Font.body)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Text("Discover if your partner’s photos appear elsewhere.")
                    .font(Tokens.Font.captionRegular)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, Tokens.Spacing.x16)
        .padding(.horizontal, Tokens.Spacing.x16)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x12)
    }

    private var pageIndicator: some View {
        // Тонкая розовая линия + серые — чисто для вида, как на скрине.
        HStack(spacing: 8) {
            Capsule().frame(width: 64, height: 3).foregroundStyle(Tokens.Color.accent)
            Capsule().frame(width: 64, height: 3).foregroundStyle(Tokens.Color.borderNeutral.opacity(0.6))
            Capsule().frame(width: 64, height: 3).foregroundStyle(Tokens.Color.borderNeutral.opacity(0.6))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, Tokens.Spacing.x16)
    }

    private var continueButton: some View {
        PrimaryButton("Continue", isLoading: vm.isLoading, isDisabled: vm.selectedPlanID == nil || vm.isLoading) {
            vm.purchaseSelected()
        }
    }

    private var linksBar: some View {
        HStack {
            Button("Privacy Policy") { /* позже откроем ссылку из настроек */ }
                .font(Tokens.Font.captionRegular)
                .foregroundStyle(Tokens.Color.textSecondary)
            Spacer()
            Button("Recover") { vm.restore() }
                .font(Tokens.Font.captionRegular)
                .foregroundStyle(Tokens.Color.textSecondary)
            Spacer()
            Button("Terms of Use") { /* позже откроем ссылку из настроек */ }
                .font(Tokens.Font.captionRegular)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
    }
}

// MARK: - Subviews

private struct PlanRow: View {
    let title: String
    let subline: String?
    let isSelected: Bool
    let isRecommended: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                radio(isOn: isSelected)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Tokens.Font.body)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    if let subline {
                        Text(subline)
                            .font(Tokens.Font.captionRegular)
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }
                }

                Spacer()

                if isRecommended {
                    Text("Save 41%")
                        .font(Tokens.Font.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Color.green,
                            in: Capsule()
                        )
                }
            }
        }
        .padding(.vertical, Tokens.Spacing.x12)
        .padding(.horizontal, Tokens.Spacing.x12)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                .stroke(isSelected ? Tokens.Color.accent : Tokens.Color.borderNeutral, lineWidth: isSelected ? 2 : 1)
        )
        .apply(Tokens.Shadow.card)
    }

    private func radio(isOn: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(Tokens.Color.borderNeutral, lineWidth: 2)
                .frame(width: 24, height: 24)
            if isOn {
                Circle()
                    .fill(Tokens.Color.accent)
                    .frame(width: 12, height: 12)
            }
        }
    }
}
