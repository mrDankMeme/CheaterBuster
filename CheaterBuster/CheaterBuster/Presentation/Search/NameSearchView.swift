//
//  NameSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//
//


import SwiftUI

struct NameSearchView: View {
    @ObservedObject var vm: SearchViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var goResults = false
    @State private var didSubmit = false

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Tokens.Spacing.x16) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .padding(12)
                            .background(
                                Tokens.Color.surfaceCard,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .apply(Tokens.Shadow.card)
                    }

                    Spacer()

                    Text("Name search")
                        .font(Tokens.Font.title)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    Spacer().frame(width: 44) // симметрия под кнопку back
                }
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x16)

                // Search field
                VStack(spacing: Tokens.Spacing.x16) {
                    SearchField("Partner's name...", text: $vm.query)
                        .padding(.horizontal, Tokens.Spacing.x16)

                    Spacer(minLength: Tokens.Spacing.x16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)

        // Bottom CTA (как в макете)
        .safeAreaInset(edge: .bottom) {
            HStack {
                PrimaryButton(
                    "Find",
                    isLoading: vm.isLoading,
                    isDisabled: vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isLoading
                ) {
                    didSubmit = true
                    vm.onSubmit()
                    vm.runNameSearch()
                }
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.vertical, Tokens.Spacing.x16)
            .background(
                Tokens.Color.backgroundMain,
                ignoresSafeAreaEdges: .bottom
            )
        }

        // Навигация к результатам после завершения
        .onChange(of: vm.isLoading) { was, isNow in
            if didSubmit && was == true && isNow == false {
                didSubmit = false
                goResults = true
            }
        }
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.results, mode: .name)
        }

        // Full-screen загрузка только по кнопке (см. vm.isBlockingLoading)
        .fullScreenCover(
            isPresented: Binding(
                get: { vm.isBlockingLoading },
                set: { _ in }
            )
        ) {
            LoadingView(mode: .name, previewImage: nil, cancelAction: nil)
                .interactiveDismissDisabled(true)
        }
    }
}
