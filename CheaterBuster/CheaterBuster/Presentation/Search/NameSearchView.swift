//
//  NameSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI

struct NameSearchView: View {
    @ObservedObject var vm: SearchViewModel

    @State private var goResults = false
    @State private var didSubmit = false

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) {
            // 🔍 Поле поиска
            SearchField("Partner's name...", text: $vm.query)

            // 🔘 Кнопка поиска + индикатор
            HStack(spacing: Tokens.Spacing.x12) {
                PrimaryButton(
                    "Find",
                    isDisabled: vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ) {
                    didSubmit = true
                    vm.onSubmit()
                    vm.runNameSearch()
                }

                if vm.isLoading {
                    ProgressView()
                }
            }

            // ❗ Ошибка, если есть
            if let err = vm.errorText {
                Text(err)
                    .foregroundStyle(.red)
                    .font(Tokens.Font.captionRegular)
            }

            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x24)
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("Name search")
        .navigationBarTitleDisplayMode(.inline)

        // 👇 Навигация к результатам — когда загрузка завершилась
        .onChange(of: vm.isLoading) { was, isNow in
            if didSubmit && was == true && isNow == false {
                didSubmit = false
                goResults = true
            }
        }

        // переход на экран результатов
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.results)
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { vm.isLoading },
                set: { _ in /* игнорируем внешние изменения */ }
            )
        ) {
            LoadingView(mode: .name, cancelAction: {
                // Тут позже можно вызвать отмену поиска
                // vm.cancelNameSearch()
            })
            .interactiveDismissDisabled(true) // запрет свайпа-вниз
        }

    }
    
}
