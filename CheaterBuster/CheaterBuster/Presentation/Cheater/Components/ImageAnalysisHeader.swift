//
//  ImageAnalysisHeader.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


// Presentation/Cheater/Components/ImageAnalysisHeader.swift
import SwiftUI

struct ImageAnalysisHeader: View {
    let back: () -> Void
    var body: some View {
        HStack {
            BackButton(size: 44.scale, action: back)
            Spacer()
            Text("Image analysis")
                .font(.system(size: 18, weight: .medium))
                .tracking(-0.18) // -1%
                .foregroundColor(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 12.scale)
    }
}

struct BackButton: View {
    let size: CGFloat
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14.scale, style: .continuous)
                    .fill(Tokens.Color.surfaceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14.scale, style: .continuous)
                            .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
                    )
                    .apply(Tokens.Shadow.card)
                if let ui = UIImage(named: "cheater_back") {
                    Image(uiImage: ui).resizable().scaledToFit()
                        .frame(width: (size * 0.55), height: (size * 0.55))
                        .foregroundColor(Tokens.Color.textPrimary)
                } else {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18.scale, weight: .semibold))
                        .foregroundColor(Tokens.Color.textPrimary)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Back"))
    }
}
