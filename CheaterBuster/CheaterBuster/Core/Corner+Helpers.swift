//
//  Corner+Helpers.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import SwiftUI

public extension View {
    @inlinable
    func cornerRadiusContinuous(_ r: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: r, style: .continuous))
    }

    @inlinable
    func roundedBorder(_ color: Color, lineWidth: CGFloat, radius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}
