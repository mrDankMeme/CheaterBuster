//
//  AppRouter.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation
import Combine

/// Центральный роутер приложения.
/// Управляет выбранной вкладкой и предпочитаемым состоянием History.
final class AppRouter: ObservableObject {
    enum Tab: Hashable { case search, cheater, history, settings }

    /// Текущая активная вкладка.
    @Published var tab: Tab = .search

    /// Предпочтительный сегмент в History (чтобы открывался нужный по умолчанию).
    @Published var historyPreferredSegment: HistoryViewModel.Segment = .search

    /// Перейти на History → сразу на Cheater-сегмент.
    func openHistoryCheater() {
        historyPreferredSegment = .cheater
        tab = .history
    }

    /// Запомнить текущий выбранный сегмент History.
    func rememberHistorySegment(_ segment: HistoryViewModel.Segment) {
        historyPreferredSegment = segment
    }
}
