//
//  HistoryViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//



import Foundation
import Combine
import UIKit

final class HistoryViewModel: ObservableObject {

    @Published private(set) var items: [HistoryRecord] = []
    @Published private(set) var cheaterItems: [CheaterRecord] = []
    @Published var segment: Segment = .search

    enum Segment: Equatable { case search, cheater }

    @Published private(set) var rerunResults: [ImageHit] = []
    @Published private(set) var isLoading = false
    @Published var errorText: String?

    @Published var selectedCheater: CheaterRecord?

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

    func clearSearch() {
        store.clearAll()
        items = []
    }

    func clearCheater() {
        cheaterStore.clearAll()
        cheaterItems = []
    }

    func onTapSearch(_ rec: HistoryRecord) {
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

    func onTapCheater(_ rec: CheaterRecord) {
        selectedCheater = rec
    }
}
