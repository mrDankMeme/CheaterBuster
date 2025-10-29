//
//  CheaterAPI.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation

protocol CheaterAPI {
    // Анализ переписки/изображения
    func createAnalyzeTask(
        files: [MultipartFormData.FilePart],
        conversation: String?
    ) async throws -> TaskReadDTO

    // Поиск по месту (endpoint /api/task/place — важна форма "file")
    func createAnalyzePlaceTask(
        file: MultipartFormData.FilePart,
        conversation: String?
    ) async throws -> TaskReadDTO

    func getAnalyzeTask(id: UUID) async throws -> TaskReadDTO

    // Реверс-поиск изображений
    func createReverseSearch(image: MultipartFormData.FilePart) async throws -> ReverseSearchCreateResponse
    func getReverseSearch(id: UUID) async throws -> ReverseSearchGetResponse
}
