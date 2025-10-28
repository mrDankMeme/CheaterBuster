//
//  ServicesAssemble.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Swinject

final class ServicesAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SearchService.self) { _ in
                SearchServiceImpl()
        }.inObjectScope(.container)
        
        container.register(CheaterAnalyzerService.self) { _ in
            CheaterAnalyzerServiceImpl()
        }.inObjectScope(.container)
     
        container.register(HistoryStore.self) { _ in
            HistoryStoreImpl()
        }.inObjectScope(.container)
        
        container.register(SettingsStore.self) { _ in SettingsStoreImpl() }
                   .inObjectScope(.container)
    }
}
