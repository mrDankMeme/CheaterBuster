// Domain/Repositories/CheaterAPI.swift
import Foundation

protocol CheaterAPI {
    func createAnalyzeTask(files: [MultipartFormData.FilePart], conversation: String?) async throws -> TaskReadDTO
    func getAnalyzeTask(id: UUID) async throws -> TaskReadDTO

    func createReverseSearch(image: MultipartFormData.FilePart) async throws -> ReverseSearchCreateResponse
    func getReverseSearch(id: UUID) async throws -> ReverseSearchGetResponse
}

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

    // /api/task
    func createAnalyzeTask(files: [MultipartFormData.FilePart], conversation: String?) async throws -> TaskReadDTO {
        let url = cfg.baseURL.appendingPathComponent("/api/task")
        var req = URLRequest(url: url); req.httpMethod = "POST"
        authed(&req)
        let mp = MultipartFormData()
        let body = mp.build(fields: [
            "conversation": conversation,
            "app_bundle": cfg.bundleId,
            "webhook_url": nil // если нужно — подставим позже
        ], files: files)
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

    // /api/search
    func createReverseSearch(image: MultipartFormData.FilePart) async throws -> ReverseSearchCreateResponse {
        let url = cfg.baseURL.appendingPathComponent("/api/search")
        var req = URLRequest(url: url); req.httpMethod = "POST"
        authed(&req)
        let mp = MultipartFormData()
        let body = mp.build(fields: [:], files: [image])
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
