//
//  CheaterScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct CheaterScreen: View {
    @State private var text: String = ""
    var body: some View {
        NavigationStack {
            VStack(spacing:16) {
                Text("Paste conversation text to analyze")
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textSecondary)
                
                TextEditor(text: $text)
                    .frame(minHeight: 160)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                    )
                PrimaryButton("Analyze", isDisabled: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ) {
                    
                }
                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("Cheater")
        }
    }
}
