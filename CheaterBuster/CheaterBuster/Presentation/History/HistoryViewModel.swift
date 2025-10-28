//
//  HistoryViewModel.swift
//  CheaterBuster
//

import Foundation
import Combine
import UIKit

final class HistoryViewModel: ObservableObject {
    // MARK: Search-history
    @Published private(set) var items: [HistoryRecord] = []

    // MARK: Cheater-history
    @Published private(set) var cheaterItems: [CheaterRecord] = []

    @Published var segment: Segment = .search
    enum Segment: Equatable { case search, cheater }

    // Навигация/статусы для реплея поиска
    @Published private(set) var rerunResults: [ImageHit] = []
    @Published private(set) var isLoading = false
    @Published var errorText: String?

    private let store: HistoryStore
    private let cheaterStore: CheaterStore
    private let search: SearchService
    private var bag = Set<AnyCancellable>()

    init(store: HistoryStore,
         cheaterStore: CheaterStore,
         search: SearchService) {
        self.store = store
        self.cheaterStore = cheaterStore
        self.search = search
        reload()
    }

    func reload() {
        items = store.load()
        cheaterItems = cheaterStore.load()
    }

    // MARK: Search tab
    func clearSearch() {
        store.clearAll()
        items = []
    }

    func onTapSearch(_ rec: HistoryRecord) {
        // повтор поиска
        isLoading = true
        errorText = nil

        let pub: AnyPublisher<[ImageHit], Error>
        if rec.kind == .name, let q = rec.query {
            pub = search.searchByName(q)
        } else if rec.kind == .face, let data = rec.imageJPEG {
            pub = search.searchByImage(data)
        } else {
            isLoading = false
            return
        }

        pub
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comp in
                self?.isLoading = false
                if case .failure(let err) = comp {
                    self?.errorText = err.localizedDescription
                }
            } receiveValue: { [weak self] hits in
                self?.rerunResults = hits
            }
            .store(in: &bag)
    }

    // MARK: Cheater tab
    func clearCheater() {
        cheaterStore.clearAll()
        cheaterItems = []
    }

    // На этом шаге «повтор анализа» не включаем, просто оставим заглушку.
    // Позже, когда подключим CheaterService, откроем экран результата/реплей задачи.
    func onTapCheater(_ rec: CheaterRecord) {
        // TODO: navigate to CheaterResultView (в следующем шаге)
    }
}
