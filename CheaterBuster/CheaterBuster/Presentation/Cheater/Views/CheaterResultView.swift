//
//  CheaterResultView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import SwiftUI

struct CheaterResultView: View {
    let record: CheaterRecord

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.x16) {
                // Заголовок + процент
                Text("Risk analysis")
                    .font(Tokens.Font.title)
                    .foregroundStyle(Tokens.Color.textPrimary)

                HStack(alignment: .firstTextBaseline, spacing: Tokens.Spacing.x12) {
                    Text("\(record.riskScore)%")
                        .font(Tokens.Font.h1)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Text(riskLevelText(record.riskScore))
                        .font(Tokens.Font.body)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }

                if let note = record.note, !note.isEmpty {
                    Text(note)
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                }

                Divider()

                // Red flags
                Text("Red flags")
                    .font(Tokens.Font.subtitle)
                    .foregroundStyle(Tokens.Color.textPrimary)

                if record.redFlags.isEmpty {
                    Text("No red flags found.")
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(record.redFlags, id: \.self) { flag in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(flag)
                            }
                            .font(Tokens.Font.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        }
                    }
                }

                Divider()

                // Recommendations
                Text("Recommendations")
                    .font(Tokens.Font.subtitle)
                    .foregroundStyle(Tokens.Color.textPrimary)

                if record.recommendations.isEmpty {
                    Text("No recommendations.")
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(record.recommendations, id: \.self) { rec in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(rec)
                            }
                            .font(Tokens.Font.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("Cheater result")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func riskLevelText(_ score: Int) -> String {
        switch score {
        case 0..<34:  return "Low risk level"
        case 34..<67: return "Medium risk level"
        default:      return "High risk level"
        }
    }
}
