//
//  SearchServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine


/// Высокоуровневый сервис поиска.
/// Работает через SearchRepository (низкий уровень) и TaskPoller (поллинг).
final class SearchServiceImpl: SearchService {
    private let repo: SearchRepository
    private let poller: TaskPoller

    init(repo: SearchRepository, poller: TaskPoller) {
        self.repo = repo
        self.poller = poller
    }

    // Поиск по имени — пока мок (E9-2 подключим реальный API при необходимости).
    func searchByName(_ query: String) -> AnyPublisher<[ImageHit], Error> {
        Just(query)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .tryMap { q in
                let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return [] }
                return (0..<6).map { i in
                    ImageHit(
                        title: "Result \(i+1) for '\(trimmed)'",
                        source: "example.com",
                        thumbnailURL: URL(string: "https://picsum.photos/seed/\(trimmed)\(i)/400/300"),
                        linkURL: URL(string: "https://example.com/\(i)")
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    // Реальный reverse image search по фото.
    func searchByImage(_ jpegData: Data) -> AnyPublisher<[ImageHit], Error> {
        Future { [repo, poller] promise in
            Task {
                do {
                    // 1) создать задачу
                    let taskId = try await repo.createReverseSearch(
                        image: jpegData,
                        filename: "image.jpg",
                        mimeType: "image/jpeg"
                    )

                    // 2) дождаться готовности всех провайдеров (google/yandex/bing)
                    let resp = try await poller.waitForReverseResult(taskId: taskId, interval: 1.0)

                    // 3) маппинг в UI-модель
                    let hits = Self.mapReverseResponseToHits(resp)
                    promise(.success(hits))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Mapping

    private static func mapReverseResponseToHits(_ resp: ReverseSearchGetResponse) -> [ImageHit] {
        // Берём google.visual_matches; при желании можно объединить с yandex/bing.
        guard let g = resp.results.google,
              let matches = g.visual_matches, !matches.isEmpty
        else { return [] }

        return matches.compactMap { vm in
            ImageHit(
                title: vm.title,
                source: vm.source,
                thumbnailURL: vm.thumbnail.flatMap(URL.init(string:)),
                linkURL: URL(string: vm.link)
            )
        }
    }
}
