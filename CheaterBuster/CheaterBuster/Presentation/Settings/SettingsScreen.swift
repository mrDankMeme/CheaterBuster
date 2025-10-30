//
//  SettingsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct SettingsScreen: View {
    // MARK: - Added
    @ObservedObject var vm: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Changed: биндим к VM вместо локального стейта
                Toggle("Save history", isOn: $vm.isHistoryEnabled)
            }
            .navigationTitle("Settings")
        }
    }
}
