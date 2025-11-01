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
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Верхняя иллюстрация
                Image("paywallHead")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270.scale, height: 270.scale)
                    .padding(.top, Tokens.Spacing.x24)
                    

                // MARK: - Заголовок
                Text("Unlock the full power of AI")
                    .font(Tokens.Font.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x12)

                // MARK: - Feature card
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Tokens.Color.surfaceCard)
                    .overlay(
                        HStack(alignment: .top, spacing: Tokens.Spacing.x12) {
                            Image("heartSearch")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .padding(.leading, 2)
                                .foregroundStyle(Tokens.Color.accent)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Check your partner")
                                    .font(Tokens.Font.body)
                                    .foregroundStyle(Tokens.Color.textPrimary)

                                Text("Discover if your partner’s photos appear elsewhere.")
                                    .font(Tokens.Font.captionRegular)
                                    .foregroundStyle(Tokens.Color.textSecondary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()
                        }

                        .padding(.vertical, Tokens.Spacing.x12)
                        .padding(.horizontal, Tokens.Spacing.x16)
                    )
                    .frame(height: 87)
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x20)

                Spacer()

                GeometryReader { geo in
                    ZStack(alignment: .bottom) {

                        // Панель с ровно верхними скруглениями
                        ZStack(alignment: .top) {
                            UnevenRoundedRectangle(
                                topLeadingRadius: 32,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 32
                            )
                            .fill(Tokens.Color.backgroundMain)
                            .shadow(color: .black.opacity(0.08), radius: 16, y: -2)

                            // 👉 Контент панели начинается на 24 pt ниже её верха
                            VStack(spacing: 0) {
                                // Plans section
                                VStack(spacing: 8) { // 👈 8 pt между рядами
                                    planRow(
                                        title: "$9.99 / month",
                                        subtitle: nil,
                                        selected: vm.selected == .monthly,
                                        fixedHeight: 56
                                    ) { vm.selected = .monthly }

                                    planRow(
                                        title: "$69.99 / year",
                                        subtitle: "$5.83 / month billed annually",
                                        selected: vm.selected == .yearly,
                                        highlighted: true,
                                        badge: "Save 41%",
                                        badgeLeading: true,        // 👈 бейдж слева от заголовка
                                        fixedHeight: 76
                                    ) { vm.selected = .yearly }
                                }
                                .padding(.horizontal, Tokens.Spacing.x16)

                                // Cancel label (16 pt от последней row)
                                Text("Cancel at any time")
                                    .font(Tokens.Font.captionRegular)
                                    .foregroundStyle(Tokens.Color.textSecondary)
                                    .padding(.top, Tokens.Spacing.x16)

                                // Continue button (16 pt от Cancel)
                                PrimaryButton(
                                    vm.isProcessing ? "Processing..." : "Continue",
                                    isLoading: vm.isProcessing,
                                    isDisabled: vm.isProcessing
                                ) {
                                    vm.buy()
                                }
                                .padding(.horizontal, Tokens.Spacing.x16)
                                .padding(.top, Tokens.Spacing.x16)

                                // Footer (16 pt от кнопки, и ровно нижний safe area)
                                HStack {
                                    Button("Privacy Policy") {}
                                    Spacer()
                                    Button("Recover") { vm.restore() }
                                    Spacer()
                                    Button("Terms of Use") {}
                                }
                                .font(Tokens.Font.captionRegular)
                                .foregroundStyle(Tokens.Color.textSecondary)
                                .padding(.horizontal, Tokens.Spacing.x16)
                                .padding(.top, Tokens.Spacing.x16)
                                .padding(.bottom, geo.safeAreaInsets.bottom) // 👈 только safe area
                            }
                            .padding(.top, Tokens.Spacing.x24) // 👈 24 pt от верхнего края панели
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 343)                 // фикс. высота панели
                        .ignoresSafeArea(edges: .bottom)    // тянем до низа
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }

            }
            
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
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
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
        }
        .alert("Error", isPresented: .constant(vm.errorText != nil), actions: {
            Button("OK") { vm.errorText = nil }
        }, message: {
            Text(vm.errorText ?? "")
        })
        .onChange(of: vm.didFinish) { _, done in
            if done { dismiss() }
        }
    }

    // MARK: - Plan row
    private func planRow(
        title: String,
        subtitle: String?,
        selected: Bool,
        highlighted: Bool = false,
        badge: String? = nil,
        badgeLeading: Bool = false,
        fixedHeight: CGFloat? = nil,
        action: @escaping () -> Void
    ) -> some View {

        let isSelected = selected
        let isFeatured = highlighted

        // цвет рамки как раньше...
        let strokeColor: SwiftUI.Color = {
            if isSelected { return Tokens.Color.accent }
            if isFeatured { return Tokens.Color.borderNeutral.opacity(0.6) }
            return Tokens.Color.borderNeutral.opacity(0.4)
        }()
        let strokeWidth: CGFloat = isSelected ? 2 : (isFeatured ? 2 : 1)

        // 👇 Цвет бейджа #00C850
        let badgeFill = SwiftUI.Color(red: 0.0, green: 200.0/255.0, blue: 80.0/255.0)

        return Button(action: action) {
            HStack(spacing: Tokens.Spacing.x12) {
                // Радио-индикатор
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Tokens.Color.accent : Tokens.Color.borderNeutral, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle().fill(Tokens.Color.accent).frame(width: 10, height: 10)
                    }
                }

                // Контент
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(Tokens.Font.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        // 👉 Бейдж ВСЕГДА справа, 98×25, отступ справа 8 pt
                        if let badge {
                            Text(badge)
                                .font(Tokens.Font.captionRegular)
                                .foregroundStyle(.white)                    // контраст на зелёном
                                .frame(width: 98, height: 25)
                                .background(Capsule().fill(badgeFill))      // #00C850
                        }
                    }

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(Tokens.Font.captionRegular)
                            .foregroundStyle(Tokens.Color.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()
            }
            .contentShape(Rectangle())
            // ⬇️ Было: .padding(.horizontal, Tokens.Spacing.x16)
            // Делаем 16 слева и ровно 8 справа, как просил
            .padding(.leading, Tokens.Spacing.x16)
            .frame(height: fixedHeight)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(strokeColor, lineWidth: strokeWidth)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Tokens.Color.surfaceCard)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }


}
