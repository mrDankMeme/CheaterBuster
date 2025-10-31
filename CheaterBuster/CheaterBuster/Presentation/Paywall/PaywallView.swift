//
//  PaywallView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI
import Combine

struct PaywallView: View {
    @ObservedObject var vm: PaywallViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Верхняя иллюстрация
            Image(systemName: "person.crop.square.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .foregroundStyle(Tokens.Color.accent.opacity(0.8))
                .padding(.top, Tokens.Spacing.x24)

            // Заголовок
            Text("Unlock the full power of AI")
                .font(Tokens.Font.title)
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x16)

            // Фича-лист (упрощённый один айтем как на макете)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .overlay(
                    HStack(alignment: .center, spacing: Tokens.Spacing.x12) {
                        Image(systemName: "heart.text.square")
                            .foregroundStyle(Tokens.Color.accent)
                            .font(.system(size: 22, weight: .semibold))
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
                    .padding(.horizontal, Tokens.Spacing.x16)
                )
                .frame(height: 88)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x16)
                .apply(Tokens.Shadow.card)

            // Планы
            VStack(spacing: Tokens.Spacing.x12) {
                planRow(
                    title: "$9.99 / month",
                    subtitle: nil,
                    selected: vm.selected == .monthly
                ) { vm.selected = .monthly }

                planRow(
                    title: "$69.99 / year",
                    subtitle: "$5.83 / month billed annually",
                    selected: vm.selected == .yearly,
                    highlighted: true,
                    badge: "Save 41%"
                ) { vm.selected = .yearly }
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)

            Text("Cancel at any time")
                .font(Tokens.Font.captionRegular)
                .foregroundStyle(Tokens.Color.textSecondary)
                .padding(.top, Tokens.Spacing.x16)

            // CTA
            PrimaryButton(
                vm.isProcessing ? "Processing..." : "Continue",
                isLoading: vm.isProcessing,
                isDisabled: vm.isProcessing
            ) {
                vm.buy()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)

            // Нижние ссылки
            HStack {
                Button("Privacy Policy") { /* TODO: открыть ссылку */ }
                Spacer()
                Button("Recover") { vm.restore() }
                Spacer()
                Button("Terms of Use") { /* TODO: открыть ссылку */ }
            }
            .font(Tokens.Font.captionRegular)
            .foregroundStyle(Tokens.Color.textSecondary)
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, Tokens.Spacing.x16)

            Spacer(minLength: 0)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .onChange(of: vm.didFinish) { _, done in
            if done { dismiss() }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .padding(12)
                    .background(
                        Tokens.Color.surfaceCard,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .padding(.trailing, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x16)
            }
            .buttonStyle(.plain)
        }
        .alert("Error", isPresented: .constant(vm.errorText != nil), actions: {
            Button("OK") { vm.errorText = nil }
        }, message: {
            Text(vm.errorText ?? "")
        })
    }

    // MARK: - Subviews

    private func planRow(
        title: String,
        subtitle: String?,
        selected: Bool,
        highlighted: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: Tokens.Spacing.x12) {
                // Radio
                ZStack {
                    Circle().strokeBorder(selected ? Tokens.Color.accent : Tokens.Color.borderNeutral, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(Tokens.Color.accent).frame(width: 10, height: 10)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(Tokens.Font.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .lineLimit(1)

                        if let badge {
                            Text(badge)
                                .font(Tokens.Font.captionRegular)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15), in: Capsule())
                        }
                    }

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(Tokens.Font.captionRegular)
                            .foregroundStyle(Tokens.Color.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, Tokens.Spacing.x12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        highlighted ? Tokens.Color.accent : Tokens.Color.borderNeutral.opacity(0.4),
                        lineWidth: highlighted ? 2 : 1
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Tokens.Color.surfaceCard)
                    )
            )
            .apply(Tokens.Shadow.card)
        }
        .buttonStyle(.plain)
    }
}
