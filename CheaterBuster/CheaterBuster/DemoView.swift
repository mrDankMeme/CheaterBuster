//
//  ContentView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//


import SwiftUI
import Swinject

struct DemoView: View {
    @State private var query = ""
    @Environment(\.resolver) private var resolver
    var body: some View {
        NavigationStack {
            Text("Boot OK")
            Text("Resolver hash: \(ObjectIdentifier(resolver as AnyObject).hashValue)")

                .font(.caption)
                .foregroundStyle(.secondary)
            VStack(spacing: Tokens.Spacing.x24) {
                SearchField("Partner's name...", text: $query)

                PrimaryButton("Find", isDisabled: query.isEmpty) {
                    // позже добавим действие
                }

                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x24)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationTitle("CheaterBuster")
        }
    }
}

