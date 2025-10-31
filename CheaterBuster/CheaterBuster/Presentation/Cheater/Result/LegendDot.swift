//
//  LegendDot.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


// Presentation/Cheater/Result/LegendDot.swift
// MARK: - Added

import SwiftUI

struct LegendDot: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 8.scale) {
            Circle()
                .fill(color)
                .frame(width: 20.scale, height: 20.scale)
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .tracking(-0.16)
                .foregroundColor(Tokens.Color.textSecondary)
        }
    }
}
