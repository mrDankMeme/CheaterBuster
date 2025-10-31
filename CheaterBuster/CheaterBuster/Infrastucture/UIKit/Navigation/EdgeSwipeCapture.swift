//
//  EdgeSwipeCapture.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/1/25.
//


//
//  EdgeSwipeBackModifier.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import SwiftUI

/// Прозрачный "ловец" свайпа от левого края, который делает pop() в NavigationStack.
/// Не зависит от UINavigationController. Работает поверх ScrollView и прочих жестов.
private struct EdgeSwipeCapture: View {
    let isEnabled: Bool
    let edgeWidth: CGFloat
    let triggerDistance: CGFloat
    let onPop: () -> Void

    @State private var started = false
    @State private var startLocation: CGPoint = .zero

    var body: some View {
        // Прозрачная зона у левого края: перехватывает жест
        Rectangle()
            .fill(Color.clear)
            .frame(width: edgeWidth)
            .contentShape(Rectangle())
            .highPriorityGesture(
                DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onChanged { value in
                        guard isEnabled else { return }
                        if !started {
                            started = true
                            startLocation = value.startLocation
                        }
                    }
                    .onEnded { value in
                        defer { started = false }
                        guard isEnabled else { return }
                        // Начало в зоне края?
                        let validStart = startLocation.x <= edgeWidth + 2
                        // Горизонтальный сдвиг вправо достаточный и без большого вертикального отклонения
                        let dx = value.translation.width
                        let dy = value.translation.height
                        if validStart && dx > triggerDistance && abs(dy) < 120 {
                            onPop()
                        }
                    }
            )
            .allowsHitTesting(isEnabled) // Чтобы не мешать, если попить нечего
    }
}

struct EdgeSwipeBackModifier: ViewModifier {
    let isEnabled: Bool
    let edgeWidth: CGFloat
    let triggerDistance: CGFloat
    let onPop: () -> Void

    func body(content: Content) -> some View {
        content
            // Кладём "ловец" поверх контента у левого края экрана
            .overlay(
                EdgeSwipeCapture(
                    isEnabled: isEnabled,
                    edgeWidth: edgeWidth,
                    triggerDistance: triggerDistance,
                    onPop: onPop
                ),
                alignment: .leading
            )
    }
}

public extension View {
    /// Включает кастомный edge-swipe назад (pop) от левого края.
    /// Работает в любых SwiftUI-экранах, независимо от UINavigationController.
    func edgeSwipeToPop(isEnabled: Bool, edgeWidth: CGFloat = 24, triggerDistance: CGFloat = 60, onPop: @escaping () -> Void) -> some View {
        modifier(EdgeSwipeBackModifier(isEnabled: isEnabled, edgeWidth: edgeWidth, triggerDistance: triggerDistance, onPop: onPop))
    }
}
