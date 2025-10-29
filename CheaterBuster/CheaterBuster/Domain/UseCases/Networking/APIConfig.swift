// Infrastructure/Networking/APIConfig.swift
import Foundation

struct APIConfig {
    let baseURL: URL
    let bundleId: String = Bundle.main.bundleIdentifier ?? "dev.cheaterbuster"
}
