//
//  TabBarAnimator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/1/25.
//


//
//  TabBarAnimator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import UIKit

/// Сдвигает системный UITabBar вниз/назад анимацией без изменения safe area и лейаута контента.
/// Использовать только из Presentation-слоя.
enum TabBarAnimator {

    /// Сдвинуть таббар вниз (true) или вернуть на место (false).
    static func set(slidDown: Bool, duration: TimeInterval = 0.25) {
        guard let tabBar = findTabBar() else { return }
        let h = tabBar.bounds.height
        UIView.animate(withDuration: duration) {
            tabBar.transform = slidDown ? CGAffineTransform(translationX: 0, y: h + 20) : .identity
        }
    }

    /// Найти системный UITabBar в иерархии текущего окна.
    private static func findTabBar() -> UITabBar? {
        guard let window = (UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first) else { return nil }
        return search(in: window)
    }

    private static func search(in view: UIView) -> UITabBar? {
        if let bar = view as? UITabBar { return bar }
        for sub in view.subviews {
            if let found = search(in: sub) { return found }
        }
        return nil
    }
}
