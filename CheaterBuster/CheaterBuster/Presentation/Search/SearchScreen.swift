//
//  SearchScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject

struct SearchScreen: View {
    @State private var goPhoto = false
    @State private var goResults = false

    private let vm: SearchViewModel
    init(vm: SearchViewModel) { self.vm = vm }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24.scale) {
                Text("Find your partner")
                    .font(.system(size: 28.scale, weight: .medium))
                    .foregroundStyle(Color(hex: "#141414"))
                    .padding(.top, Tokens.Spacing.x8.scale)

                Button { goPhoto = true } label: {
                    VStack(spacing: 16.scale) {
                        Image("faceSearchIcon")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40.scale, height: 40.scale)

                        Text("Finding a partner by face")
                            .font(.system(size: 16.scale, weight: .regular))
                            .foregroundStyle(Color(hex: "#141414"))
                    }
                    .frame(maxWidth: .infinity, minHeight: 160.scale)
                    .background(
                        RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: Color(hex: "#ACACAC").opacity(0.1),
                            radius: 9.scale, y: 2.scale)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16.scale)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())

            .navigationDestination(isPresented: $goPhoto) {
                FaceSearchView(vm: vm, onFinished: { goResults = true })
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $goResults) {
                SearchResultsView(results: vm.results, mode: .face)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
