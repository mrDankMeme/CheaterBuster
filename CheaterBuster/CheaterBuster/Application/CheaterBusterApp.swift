//
//  CheaterBusterApp.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/27/25.
//

import SwiftUI
import Swinject

@main
struct CheaterBusterApp: App {

    private let assembler = AppAssembler.make()
    private var resolver: Resolver { assembler.resolver }

    init() {
        // сидим СРАЗУ при старте приложения
        DevSeed.run(resolver)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.resolver, resolver)
        }
    }
}
