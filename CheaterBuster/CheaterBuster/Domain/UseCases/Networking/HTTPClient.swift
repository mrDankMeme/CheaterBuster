//
//  HTTPClient.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


// Domain/Abstractions/Networking/HTTPClient.swift
import Foundation

public protocol HTTPClient {
    func send<T: Decodable>(_ request: URLRequest) async throws -> T
    func sendVoid(_ request: URLRequest) async throws
}

public enum APIError: Error {
    case invalidURL
    case http(Int, String?)
    case decoding(Error)
    case transport(Error)
    case noData
    case unauthorized
}
