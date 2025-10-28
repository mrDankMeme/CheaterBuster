//
//  ViewModelsAssembly.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Swinject

final class ViewModelsAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SearchViewModel.self) { r in
            SearchViewModel(search: r.resolve(SearchService.self)!,
                            history: r.resolve(HistoryStore.self)!,
                            settings: r.resolve(SettingsStore.self)!)
        }
        container.register(CheaterViewModel.self) { r in
            CheaterViewModel(analyzer: r.resolve(CheaterAnalyzerService.self)!)
        }
      
        container.register(HistoryViewModel.self) { r in
            HistoryViewModel(
                store: r.resolve(HistoryStore.self)!,
                cheaterStore: r.resolve(CheaterStore.self)!,
                search: r.resolve(SearchService.self)!
            )
        }
        
        container.register(SettingsViewModel.self) { r in
            SettingsViewModel(store: r.resolve(SettingsStore.self)!)
        }
    }
}
