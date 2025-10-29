//
//  Services+VMAssembly.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Swinject

final class ServicesAssembly: Assembly {
    func assemble(container: Container) {

        // MARK: Infrastructure
        container.register(APIConfig.self) { _ in
            APIConfig(baseURL: URL(string: "https://cheaterbuster.webberapp.shop")!)
        }
        .inObjectScope(.container)

        container.register(TokenStorage.self) { _ in InMemoryTokenStorage() }
            .inObjectScope(.container)

        container.register(HTTPClient.self) { _ in URLSessionHTTPClient() }
            .inObjectScope(.container)

        // MARK: App router
        container.register(AppRouter.self) { _ in AppRouter() }
            .inObjectScope(.container)

        // MARK: Domain / Auth
        container.register(AuthRepository.self) { r in
            AuthRepositoryImpl(
                cfg: r.resolve(APIConfig.self)!,
                http: r.resolve(HTTPClient.self)!,
                tokens: r.resolve(TokenStorage.self)!
            )
        }
        .inObjectScope(.container)

        // MARK: Domain / API
        container.register(CheaterAPI.self) { r in
            CheaterAPIImpl(
                cfg: r.resolve(APIConfig.self)!,
                http: r.resolve(HTTPClient.self)!,
                tokens: r.resolve(TokenStorage.self)!
            )
        }
        .inObjectScope(.container)

        // MARK: Domain / Tasks
        container.register(TaskPoller.self) { r in
            TaskPollerImpl(api: r.resolve(CheaterAPI.self)!)
        }
        .inObjectScope(.container)

        // MARK: Domain Stores & Services
        container.register(HistoryStore.self) { _ in HistoryStoreImpl() }
            .inObjectScope(.container)

        container.register(CheaterStore.self) { _ in CheaterStoreImpl() }
            .inObjectScope(.container)

        container.register(SettingsStore.self) { _ in SettingsStoreImpl() }
            .inObjectScope(.container)

        container.register(SearchService.self) { _ in SearchServiceImpl() }
            .inObjectScope(.container)

        container.register(CheaterAnalyzerService.self) { _ in CheaterAnalyzerServiceImpl() }
            .inObjectScope(.container)

        // MARK: ViewModels
        container.register(SearchViewModel.self) { r in
            SearchViewModel(
                search: r.resolve(SearchService.self)!,
                history: r.resolve(HistoryStore.self)!,
                settings: r.resolve(SettingsStore.self)!
            )
        }

        container.register(HistoryViewModel.self) { r in
            HistoryViewModel(
                store: r.resolve(HistoryStore.self)!,
                cheaterStore: r.resolve(CheaterStore.self)!,
                search: r.resolve(SearchService.self)!
            )
        }

        container.register(CheaterViewModel.self) { r in
            CheaterViewModel(
                auth: r.resolve(AuthRepository.self)!,
                api: r.resolve(CheaterAPI.self)!,
                poller: r.resolve(TaskPoller.self)!,
                store: r.resolve(CheaterStore.self)!,
                cfg: r.resolve(APIConfig.self)!
            )
        }
    }
}
