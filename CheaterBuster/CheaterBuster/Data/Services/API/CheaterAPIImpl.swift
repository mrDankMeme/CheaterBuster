//
//  CheaterAPIImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


// Data/Services/API/CheaterAPIImpl.swift
import Foundation

final class CheaterAPIImpl: CheaterAPI {
    private let cfg: APIConfig
    private let http: HTTPClient
    private let tokens: TokenStorage

    init(cfg: APIConfig, http: HTTPClient, tokens: TokenStorage) {
        self.cfg = cfg; self.http = http; self.tokens = tokens
    }

    private func authed(_ req: inout URLRequest) {
        if let t = tokens.accessToken {
            req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
    }

    // MARK: - /api/task (files[], conversation?, app_bundle*, webhook_url?)
    func createAnalyzeTask(
        files: [MultipartFormData.FilePart],
        conversation: String?
    ) async throws -> TaskReadDTO {
        let url = cfg.baseURL.appendingPathComponent("/api/task")
        var req = URLRequest(url: url); req.httpMethod = "POST"
        authed(&req)

        let mp = MultipartFormData()
        let body = mp.build(fields: [
            "conversation": conversation,
            "app_bundle": cfg.bundleId,
            "webhook_url": nil
        ], files: files.map { part in
            // поле должно называться "files" (массив), даже если один файл
            MultipartFormData.FilePart(
                name: "files",
                filename: part.filename,
                mimeType: part.mimeType,
                data: part.data
            )
        })
        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return try await http.send(req)
    }

    // MARK: - /api/task/place (file, conversation?, app_bundle*, webhook_url?)
    func createAnalyzePlaceTask(
        file: MultipartFormData.FilePart,
        conversation: String?
    ) async throws -> TaskReadDTO {
        let url = cfg.baseURL.appendingPathComponent("/api/task/place")
        var req = URLRequest(url: url); req.httpMethod = "POST"
        authed(&req)

        let mp = MultipartFormData()
        // строго одно поле "file"
        let one = MultipartFormData.FilePart(
            name: "file",
            filename: file.filename,
            mimeType: file.mimeType,
            data: file.data
        )
        let body = mp.build(fields: [
            "conversation": conversation,
            "app_bundle": cfg.bundleId,
            "webhook_url": nil
        ], files: [one])
        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return try await http.send(req)
    }

    func getAnalyzeTask(id: UUID) async throws -> TaskReadDTO {
        let url = cfg.baseURL.appendingPathComponent("/api/task/\(id.uuidString)")
        var req = URLRequest(url: url)
        authed(&req)
        return try await http.send(req)
    }

    // MARK: - Reverse search (без изменений в контракте)
    func createReverseSearch(image: MultipartFormData.FilePart) async throws -> ReverseSearchCreateResponse {
        let url = cfg.baseURL.appendingPathComponent("/api/search")
        var req = URLRequest(url: url); req.httpMethod = "POST"
        authed(&req)
        let mp = MultipartFormData()
        let body = mp.build(fields: [:], files: [
            MultipartFormData.FilePart(
                name: "image",
                filename: image.filename,
                mimeType: image.mimeType,
                data: image.data
            )
        ])
        req.setValue(mp.contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return try await http.send(req)
    }

    func getReverseSearch(id: UUID) async throws -> ReverseSearchGetResponse {
        let url = cfg.baseURL.appendingPathComponent("/api/search/\(id.uuidString)")
        var req = URLRequest(url: url)
        authed(&req)
        return try await http.send(req)
    }
}
