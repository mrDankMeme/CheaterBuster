//
//  DesignTokens.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI

public enum Tokens {
    
    // MARK: Colors (Figma -> SwiftUI)
    public enum Color {
        public static let accent = SwiftUI.Color("Accent")
        public static let accentPressed = SwiftUI.Color("AccentPressed")
        
        public static let textPrimary = SwiftUI.Color("TextPrimary")
        public static let textSecondary = SwiftUI.Color("TextSecondary")
        
        public static let borderNeutral = SwiftUI.Color("BorderNeutral")
        public static let backgroundMain = SwiftUI.Color("BackgroundMain")
        public static let shadowBlack7 = SwiftUI.Color("ShadowBlack7")
        public static let surfaceCard = SwiftUI.Color("SurfaceCard")
    }
    
    //MARK: Typography (SF Pro)
    public enum Font {
        public static let h1 = SwiftUI.Font.system(size:32, weight: .semibold)
        public static let h2 = SwiftUI.Font.system(size:28, weight: .medium)
        public static let title = SwiftUI.Font.system(size:22, weight: .medium)
        public static let subtitle = SwiftUI.Font.system(size:20, weight: .bold)
        public static let body = SwiftUI.Font.system(size:20, weight: .regular)
        public static let bodyMedium18 = SwiftUI.Font.system(size:18, weight: .medium)
        static let bodyMedium = SwiftUI.Font.system(size: 16, weight: .medium)
        public static let caption = SwiftUI.Font.system(size: 15, weight: .medium)
        public static let captionRegular = SwiftUI.Font.system(size: 15, weight: .regular)
    }
    
    //MARK: Spacing & Radius
    
    public enum Spacing {
        public static let x4:  CGFloat = 4
        public static let x8:  CGFloat = 8
        public static let x12: CGFloat = 12
        public static let x16: CGFloat = 16
        public static let x20: CGFloat = 20
        public static let x24: CGFloat = 24
        public static let x32: CGFloat = 32
    }
    
    public enum Radius {
        public static let pill:   CGFloat = 24
        public static let medium: CGFloat = 16
        public static let small:  CGFloat = 12
    }
    
    // MARK: Shadow
    public enum Shadow {
        public static let card = ShadowStyle(
            color: .black.opacity(0.07),
            radius: 12,
            y: 6
        )
    }
    
}

// MARK: Helpers
public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let y: CGFloat
}

public extension View {
    func apply(_ shadow: ShadowStyle) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
    }
}
