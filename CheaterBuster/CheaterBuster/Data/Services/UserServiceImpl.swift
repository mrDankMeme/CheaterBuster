//
//  UserServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


//
//  UserServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/30/25.
//

import Foundation

final class UserServiceImpl: UserService {
    private let cfg: APIConfig
    private let http: HTTPClient
    private let tokensStorage: TokenStorage
    private var tokensStore: TokensStore

    init(cfg: APIConfig,
         http: HTTPClient,
         tokensStorage: TokenStorage,
         tokensStore: TokensStore)
    {
        self.cfg = cfg
        self.http = http
        self.tokensStorage = tokensStorage
        self.tokensStore = tokensStore
    }

    func fetchMe() async throws -> UserReadDTO {
        let url = cfg.baseURL.appendingPathComponent("/api/user/me")
        var req = URLRequest(url: url)
        // MARK: - Added: auth header
        if let t = tokensStorage.accessToken {
            req.setValue("Bearer \(t)", forHTTPHeaderField: "Authorization")
        }
        let me: UserReadDTO = try await http.send(req)
        // Пишем баланс токенов в локальный стор (используем далее в UI/гейте)
        tokensStore.tokens = me.tokens
        return me
    }
}
