//
//  NameSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import SwiftUI

struct NameSearchView: View {
    @ObservedObject var vm: SearchViewModel
    @State private var goResults = false

    var body: some View {
        VStack(spacing: Tokens.Spacing.x16) {
            SearchField("Partner's name...", text: $vm.query)

            HStack {
                PrimaryButton("Find", isDisabled: vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    vm.onSubmit()           // сохраняем в историю (если включено)
                    vm.runNameSearch()      // явный старт поиска (мгновенно)
                }

                if vm.isLoading {
                    ProgressView()
                }
            }

            if let err = vm.errorText {
                Text(err).foregroundStyle(.red)
            }

            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x24)
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationTitle("Name search")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(vm.$results) { _ in
            // когда результаты обновились после запроса — идём на экран списка
            if !vm.isLoading { goResults = true }
        }
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.results)
        }
    }
}
