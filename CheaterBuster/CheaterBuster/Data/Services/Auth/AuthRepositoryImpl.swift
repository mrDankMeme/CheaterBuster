//
//  AuthRepositoryImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let cfg: APIConfig
    private let http: HTTPClient
    private var tokens: TokenStorage

    init(cfg: APIConfig, http: HTTPClient, tokens: TokenStorage) {
        self.cfg = cfg; self.http = http; self.tokens = tokens
    }

    var isAuthorized: Bool { tokens.accessToken != nil }

    func ensureAuthorized(apphudId: String) async throws {
        if tokens.accessToken != nil { return }
        let createURL = cfg.baseURL.appendingPathComponent("/api/user")
        var r1 = URLRequest(url: createURL)
        r1.httpMethod = "POST"
        r1.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r1.httpBody = try JSONEncoder().encode(CreateUserDTO(apphud_id: apphudId))
        let created: UserReadDTO = try await http.send(r1)
        tokens.userId = created.id.uuidString

        let authURL = cfg.baseURL.appendingPathComponent("/api/user/authorize")
        var r2 = URLRequest(url: authURL)
        r2.httpMethod = "POST"
        r2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        r2.httpBody = try JSONEncoder().encode(AuthorizeUserDTO(user_id: created.id))
        let token: TokenResponseDTO = try await http.send(r2)
        tokens.accessToken = token.access_token
    }
}