//
//  SearchRepository.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//




import Foundation

/// Низкоуровневый доступ к reverse image search API.
/// Репозиторий ничего не знает о Combine/SwiftUI и не занимается поллингом.
protocol SearchRepository {
    /// Создать задачу reverse-search и вернуть её id.
    func createReverseSearch(image: Data, filename: String, mimeType: String) async throws -> UUID

    /// Получить состояние/результат по taskId.
    func getReverseSearch(taskId: UUID) async throws -> ReverseSearchGetResponse
}
