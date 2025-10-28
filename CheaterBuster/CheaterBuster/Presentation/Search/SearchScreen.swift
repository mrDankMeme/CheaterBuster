//
//  SearchScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct SearchScreen : View {
    @State private var query = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SearchField("Partner's name", text: $query)
                PrimaryButton("Find") {
                    
                }
                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationBarTitle("Search")
        }
    }
}
