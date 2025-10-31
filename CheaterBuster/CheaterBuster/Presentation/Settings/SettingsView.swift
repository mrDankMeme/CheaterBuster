//
//  SettingsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var vm: SettingsViewModel

    init(vm: SettingsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Save history", isOn: $vm.isHistoryEnabled)
            }
            .navigationTitle("Settings")
        }
    }
}
