//
//  DevSeed.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import Foundation
import Swinject

enum DevSeed {
    static func run(_ resolver: Resolver) {
        #if DEBUG
        guard let store = resolver.resolve(CheaterStore.self) else { return }

        // Чтобы не дублировать при каждом запуске — только если история пустая
        if store.load().isEmpty {
            store.add(.init(kind: .image, riskScore: 80, note: "WhatsApp screenshot"))
            store.add(.init(kind: .file,  riskScore: 92, note: "PDF contract"))
        }
        #endif
    }
}
