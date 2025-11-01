//
//  CheaterResultView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

private struct ResultModel: Equatable {
    let riskScore: Int
    let redFlags: [String]
    let recommendations: [String]
}

struct CheaterResultView: View {
    private let model: ResultModel
    private let onBack: () -> Void
    private let onSelectMessage: () -> Void
    private let analysisTitle: String

    init(
        result: TaskResult,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {},
        analysisTitle: String = "Image analysis"
    ) {
        self.model = .init(
            riskScore: result.risk_score,
            redFlags: result.red_flags,
            recommendations: result.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
        self.analysisTitle = analysisTitle
    }

    init(
        record: CheaterRecord,
        onBack: @escaping () -> Void = {},
        onSelectMessage: @escaping () -> Void = {},
        analysisTitle: String = "Image analysis"
    ) {
        self.model = .init(
            riskScore: record.riskScore,
            redFlags: record.redFlags,
            recommendations: record.recommendations
        )
        self.onBack = onBack
        self.onSelectMessage = onSelectMessage
        self.analysisTitle = analysisTitle
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    summaryBlock
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 8.scale)

                    // MARK: Red flags
                    if !model.redFlags.isEmpty {
                        Text("Red flasg")
                            .font(.system(size: 18.scale, weight: .medium))
                            .tracking(-0.18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 16.scale)
                            .padding(.top, 32.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.redFlags, id: \.self) { txt in
                                RedFlagCard(
                                    title: "Suspicious languagw delected",
                                    subtitle: "Phrase: \(txt)"
                                )
                            }
                        }
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 16.scale)
                        .padding(.bottom, 32.scale) // ← Added: отступ вниз перед блоком Recommendations
                    }

                    // MARK: Если флагов нет, даём отступ от легенды к “Recommendations”
                    if model.redFlags.isEmpty && !model.recommendations.isEmpty {
                        Spacer().frame(height: 24.scale) // ← Added ранее: кейс без RedFlags
                    }

                    // MARK: Recommendations
                    if !model.recommendations.isEmpty {
                        Text("Recommendations")
                            .font(.system(size: 18, weight: .medium))
                            .tracking(-0.18)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(.horizontal, 16.scale)

                        VStack(spacing: 8.scale) {
                            ForEach(model.recommendations, id: \.self) { rec in
                                RecommendationCard(
                                    title: "Save evidence",
                                    subtitle: rec
                                )
                            }
                        }
                        .padding(.horizontal, 16.scale)
                        .padding(.top, 16.scale)
                    }

                    PrimaryButton("Select message") {
                        onSelectMessage()
                    }
                    .padding(.horizontal, 16.scale)
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
            Text(analysisTitle)
                .font(.system(size: 18.scale, weight: .medium))
                .tracking(-0.18)
                .foregroundStyle(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.top, 10.scale)
        .padding(.bottom, 8.scale)
        .background(Tokens.Color.backgroundMain)
    }

    // MARK: - Summary Block
    private var summaryBlock: some View {
        VStack(spacing: 0) {
            // Title + icon
            HStack(alignment: .center, spacing: 8.scale) {
                Text("Risk analysis complete")
                    .font(.system(size: 22, weight: .medium))
                    .tracking(-0.22)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Image("tickSquare")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 24.scale, height: 24.scale)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // Subtitle
            Text(detectedSubtitle(for: model.riskScore))
                .font(.system(size: 16, weight: .medium))
                .tracking(-0.16)
                .foregroundStyle(Tokens.Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8.scale)

            // Ring
            RiskRingView(percent: model.riskScore)
                .frame(width: 120.scale, height: 120.scale)
                .frame(maxWidth: .infinity)
                .padding(.top, 24.scale)

            // Risk level text
            Text(riskLevelLabel(for: model.riskScore))
                .font(.system(size: 20.scale, weight: .regular))
                .tracking(-0.20)
                .foregroundStyle(Tokens.Color.textSecondary)
                .padding(.top, 16.scale)

            // Legend
            HStack(spacing: 24.scale) {
                legendDot(.green, text: "Low")
                legendDot(.yellow, text: "Medium")
                legendDot(.red, text: "High")
            }
            .padding(.top, 16.scale)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func legendDot(_ color: Color, text: String) -> some View {
        HStack(spacing: 8.scale) {
            Circle()
                .fill(color)
                .frame(width: 20.scale, height: 20.scale)
            Text(text)
                .font(.system(size: 16.scale, weight: .medium))
                .tracking(-0.16)
                .foregroundStyle(Tokens.Color.textSecondary)
        }
    }

    private func riskLevelLabel(for score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
    }

    private func detectedSubtitle(for score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk detected in this message"
        case 34..<67: return "Medium risk detected in this message"
        default:      return "High risk detected in this message"
        }
    }
}
