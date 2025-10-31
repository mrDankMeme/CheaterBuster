//  Presentation/Cheater/Result/RiskRingView.swift
//  CheaterBuster
//
//  Updated: lineWidth = 17.scale, 32 semibold text with -4% tracking.

import SwiftUI

struct RiskRingView: View {
    let percent: Int // 0...100

    var body: some View {
        ZStack {
            // Grey track
            Circle()
                .stroke(Color.black.opacity(0.08),
                        style: StrokeStyle(lineWidth: 17.scale, lineCap: .round))

            // Colored progress (red → yellow → green)
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(1, Double(percent) / 100.0))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FA2C37"),
                            Color(hex: "#FDC800"),
                            Color(hex: "#FDC800"),
                            Color(hex: "#00C850")
                        ]),
                        center: .center,
                        startAngle: .degrees(210),
                        endAngle: .degrees(570)
                    ),
                    style: StrokeStyle(lineWidth: 17.scale, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(percent)%")
                .font(.system(size: 32, weight: .semibold))
                .kerning(-0.04 * 32) // ≈ -4%
                .foregroundColor(Tokens.Color.textPrimary)
        }
    }
}
