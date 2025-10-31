//
//  InteractivePopConfigurator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import SwiftUI
import UIKit

/// Включает системный интерактивный "свайп от левого края" для NavigationStack.
/// НИКАКИХ своих делегатов — используем стандартную реализацию UINavigationController.
struct InteractivePopConfigurator: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard
            let nav = uiViewController.navigationController,
            let pop = nav.interactivePopGestureRecognizer
        else { return }

        pop.isEnabled = true
        pop.delegate = nil // ← ключевой момент: вернуть системного делегата
    }
}

public extension View {
    /// Подвешивает конфигуратор к текущему представлению.
    func enableInteractivePop() -> some View {
        background(InteractivePopConfigurator())
    }
}
