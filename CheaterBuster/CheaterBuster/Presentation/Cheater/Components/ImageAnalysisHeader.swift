//  ImageAnalysisHeader.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct ImageAnalysisHeader: View {
    let back: () -> Void

    var body: some View {
        HStack {
            BackButton(size: 44.scale, action: back)
            Spacer()
            Text("Image analysis")
                .font(.system(size: 18, weight: .medium))
                .tracking(-0.18)
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
    
    // MARK: - Tunables (подгонка под твой PNG)
    private let glyphScale: CGFloat = 0.72   // доля от контейнера (44 * 0.72 ≈ 32pt)
    private let trimPadding: CGFloat = -4    // компенсируем прозрачные поля PNG
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Подложка без бордера + слои тени
                RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                    .fill(.white)
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.10), radius: 5.scale,  x: 0, y: 2.scale)
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.09), radius: 9.scale,  x: 0, y: 9.scale)
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.06), radius: 18.scale, x: 0, y: 14.scale)
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.04), radius: 32.scale, x: 0, y: 24.scale)
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.03), radius: 48.scale, x: 0, y: 36.scale)
                
                // Иконка из ассета (увеличена и “подрезана”)
                if let ui = UIImage(named: "backButton") {
                    Image(uiImage: ui)
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: size * glyphScale/1.5, height: size * glyphScale/1.5)
                        .padding(trimPadding.scale) // MARK: - Added
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20.scale, weight: .semibold))
                        .foregroundColor(Tokens.Color.textPrimary)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Back"))
    }
}
