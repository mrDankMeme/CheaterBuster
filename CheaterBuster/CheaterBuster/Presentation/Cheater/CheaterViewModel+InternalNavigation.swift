//
//  CheaterViewModel+InternalNavigation.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

// MARK: - Changed: goBackToIdle теперь ещё и отменяет анализ
extension CheaterViewModel {
    /// Возвращает экран Cheater в начальное состояние (idle)
    /// и корректно отменяет текущий анализ, если он ещё идёт.
    func goBackToIdle() {
        cancelCurrentAnalysis() // MARK: - Added
        self.state = .idle
    }
}

