//
//  CheaterViewModel+InternalNavigation.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation

// MARK: - Added
extension CheaterViewModel {
    /// Возвращает экран Cheater в начальное состояние (idle),
    /// как будто пользователь нажал "назад" с предпросмотра.
    func goBackToIdle() {
        self.state = .idle
    }
}
