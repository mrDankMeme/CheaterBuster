//
//  AppRouter.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation
import Combine

/// Простой роутер уровня приложения: выбранная вкладка.
final class AppRouter: ObservableObject {
    enum Tab: Hashable { case search, cheater, history, settings }
    @Published var tab: Tab = .search
}
