//
//  RiskRingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


// Presentation/Cheater/Result/RiskRingView.swift
// MARK: - Added

import SwiftUI

struct RiskRingView: View {
    let percent: Int   // 0...100

    var body: some View {
        ZStack {
            // серый трек
            Circle()
                .stroke(Color.black.opacity(0.08), style: StrokeStyle(lineWidth: 16.scale, lineCap: .round))

            // цветной градиентный прогресс
            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(1, Double(percent) / 100.0))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#FA2C37"),  // red
                            Color(hex: "#FDC800"),  // yellow
                            Color(hex: "#00C850")   // green
                        ]),
                        center: .center,
                        startAngle: .degrees(210), // подобрано под макет
                        endAngle: .degrees(210 + 360)
                    ),
                    style: StrokeStyle(lineWidth: 16.scale, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // 32 Semibold, -4%
            Text("\(percent)%")
                .font(.system(size: 32, weight: .semibold))
                .kerning(-0.04 * 32 / 1.0) // лёгкий оптический кернинг
                .foregroundColor(Tokens.Color.textPrimary)
        }
    }
}
