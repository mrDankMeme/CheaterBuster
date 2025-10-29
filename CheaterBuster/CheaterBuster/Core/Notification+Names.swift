//
//  Notification+Names.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

/// Centralized notification names used across modules.
extension Notification.Name {
    /// Sent when the user saves a cheater analysis and taps “Open History”.
    static let openHistoryCheater = Notification.Name("openHistoryCheater")
}
