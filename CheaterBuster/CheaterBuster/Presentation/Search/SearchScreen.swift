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
    private let vm: SearchViewModel

    init(vm: SearchViewModel) { self.vm = vm }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Tokens.Spacing.x16.scale) {
                // MARK: - Заголовок
                Text("Find your partner")
                    .font(.system(size: 28.scale, weight: .medium))
                    .foregroundStyle(Color(hex: "#141414"))
                    .padding(.top, Tokens.Spacing.x8.scale)

                // MARK: - Карточка
                Button {
                    goPhoto = true
                } label: {
                    VStack(spacing: 16.scale) {
                        Image("faceSearchIcon") // добавь в Assets
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
                FaceSearchView(vm: vm)
            }
        }
    }
}
