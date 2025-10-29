//
//  AppRouter.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//



import Foundation
import Combine


final class AppRouter: ObservableObject {
    enum Tab: Hashable { case search, cheater, history, settings }

    /// Текущая вкладка.
    @Published var tab: Tab = .search

    /// Какой сегмент показывать в History при открытии.
    /// По умолчанию `.search`. Меняем на `.cheater`, когда хотим открыть Cheater-сегмент.
    @Published var historyPreferredSegment: HistoryViewModel.Segment = .search

    /// Удобный helper: переключить на History и сразу выбрать Cheater-сегмент.
    func openHistoryCheater() {
        historyPreferredSegment = .cheater
        tab = .history
    }
}
