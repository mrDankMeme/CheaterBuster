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

    // получаем роутер из DI
    private var router: AppRouter { resolver.resolve(AppRouter.self)! }

    init() {
        DevSeed.run(resolver)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(\.resolver, resolver)
                .environmentObject(router)
        }
    }
}
