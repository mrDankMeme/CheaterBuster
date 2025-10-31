// Presentation/Cheater/Result/CheaterResultView.swift

import SwiftUI

// MARK: - Screen Model (унифицируем вход)
private struct ResultModel: Equatable {
    let riskScore: Int
    let redFlags: [String]
    let recommendations: [String]
}

// MARK: - View
struct CheaterResultView: View {

    // Inputs
    private let model: ResultModel
    private let onBack: () -> Void
    private let onSelectMessage: () -> Void

    // MARK: - Inits (анализ → экран)
    init(
        result: TaskResult,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {}
    ) {
        self.model = .init(
            riskScore: result.risk_score,
            redFlags: result.red_flags,
            recommendations: result.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
    }

    // MARK: - Inits (история → экран)
    init(
        record: CheaterRecord,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {}
    ) {
        self.model = .init(
            riskScore: record.riskScore,
            redFlags: record.redFlags,
            recommendations: record.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Легенда Low / Medium / High
                    legendBlock
                        .padding(.horizontal, 8.scale)   // MARK: - Changed (16 → 8)
                        .padding(.top, 16.scale)

                    // Red flags
                    if !model.redFlags.isEmpty {
                        Text("Red flasg")
                            .font(Tokens.Font.bodyMedium18)
                            .tracking(-0.18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 8.scale)  // MARK: - Changed
                            .padding(.top, 32.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.redFlags, id: \.self) { txt in
                                RedFlagCard(
                                    title: "Suspicious languagw delected",
                                    subtitle: "Phrase: \(txt)"
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 8.scale)     // MARK: - Changed
                        .padding(.top, 16.scale)
                    }

                    // Recommendations
                    if !model.recommendations.isEmpty {
                        Text("Recommendations")
                            .font(Tokens.Font.bodyMedium18)
                            .tracking(-0.18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 8.scale)  // MARK: - Changed
                            .padding(.top, 32.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.recommendations, id: \.self) { rec in
                                RecommendationCard(
                                    title: "Save evidence",
                                    subtitle: rec
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 8.scale)     // MARK: - Changed
                        .padding(.top, 16.scale)
                    }

                    // CTA
                    PrimaryButton("Select message") {
                        onSelectMessage()
                    }
                    .padding(.horizontal, 8.scale)         // MARK: - Changed
                    .padding(.vertical, 24.scale)
                }
            }
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 0) {
            BackButton(size: 44.scale, action: onBack)
            Spacer()
            Text("Image analysis")
                .font(Tokens.Font.bodyMedium18) // medium 18
                .tracking(-0.18)
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
            // симметрия
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale) // оставил как было
        .padding(.top, 10.scale)
        .padding(.bottom, 8.scale)
        .background(Tokens.Color.backgroundMain)
    }

    // MARK: - Legend
    private var legendBlock: some View {
        VStack(spacing: 12.scale) {
            Text(riskLevelText(model.riskScore))
                .font(Tokens.Font.body) // 20 Regular
                .tracking(-0.20)
                .foregroundStyle(Tokens.Color.textSecondary)

            HStack(spacing: 24.scale) {
                legendDot(.green, text: "Low")
                legendDot(.yellow, text: "Medium")
                legendDot(.red, text: "High")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func legendDot(_ color: Color, text: String) -> some View {
        HStack(spacing: 8.scale) {
            Circle()
                .fill(color)
                .frame(width: 20.scale, height: 20.scale)
            Text(text)
                .font(Tokens.Font.captionRegular) // 15 Regular
                .tracking(-0.15)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
    }

    private func riskLevelText(_ score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
    }
}
