//
//  SettingsView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct SettingsScreen: View {
    @State private var isHistoryEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Save history", isOn: $isHistoryEnabled)
            }
            .navigationTitle("Settings")
        }
    }
}
