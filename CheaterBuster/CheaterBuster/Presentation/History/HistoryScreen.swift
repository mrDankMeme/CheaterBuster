//
//  HistoryScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct HistoryScreen: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No history",
                systemImage: "clock",
                description: Text("Your last 10 searches will appear here.")
            )
            .navigationTitle("History")
        }
    }
}

