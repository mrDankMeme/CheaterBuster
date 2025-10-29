//
//  SettingsStoreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

final class SettingsStoreImpl: SettingsStore {
    private let key = "isHistoryEnabled"

    // Хотим дефолт = true. bool(forKey:) даёт false, если ключ не записан.
    // Поэтому, если ключа нет — возвращаем true.
    var isHistoryEnabled: Bool {
        get {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: key) == nil {
                return true
            }
            return defaults.bool(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
