// Presentation/Cheater/Result/RecommendationCard.swift
// MARK: - Added

import SwiftUI

struct RecommendationCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12.scale) {
            Image("tickCircle") // 20×20
                .resizable()
                .renderingMode(.original)
                .frame(width: 20.scale, height: 20.scale)
                .padding(.top, 2.scale)

            VStack(alignment: .leading, spacing: 8.scale) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))   // ✅ 16 Medium
                    .tracking(-0.16)
                    .foregroundColor(Tokens.Color.textPrimary)

                Text(subtitle)
                    .font(.system(size: 15, weight: .regular))  // ✅ 15 Regular
                    .tracking(-0.15)
                    .foregroundColor(Tokens.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 14.scale)
        .padding(.horizontal, 16.scale)
        .frame(maxWidth: .infinity)
        .background(
            Color(hex: "#ECFAF0"),
            in: RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
                .stroke(Color(hex: "#BDEACB"), lineWidth: 1)
        )
    }
}
