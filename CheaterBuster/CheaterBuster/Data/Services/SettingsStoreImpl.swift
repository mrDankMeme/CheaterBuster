//
//  SettingsStoreImplementation.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation

final class SettingsStoreImpl: SettingsStore {
    private let key = "isHistoryEnabled"
    var isHistoryEnabled: Bool {
        get { UserDefaults.standard.objectIsForced(forKey: key) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue,forKey:  key) }
    }
    
    
}
