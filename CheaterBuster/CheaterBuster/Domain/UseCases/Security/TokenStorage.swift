// Infrastructure/Security/TokenStorage.swift
import Foundation

protocol TokenStorage {
    var accessToken: String? { get set }
    var userId: String? { get set }
}

final class InMemoryTokenStorage: TokenStorage {
    var accessToken: String?
    var userId: String?
}
// при желании быстро меняется на Keychain
