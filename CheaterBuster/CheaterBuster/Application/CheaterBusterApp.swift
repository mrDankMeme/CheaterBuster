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
    
    var body: some Scene {
        WindowGroup {
            DemoView().environment(\.resolver, assembler.resolver)
        }
    }
}
