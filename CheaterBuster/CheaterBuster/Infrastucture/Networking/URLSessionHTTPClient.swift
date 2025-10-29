//
//  URLSessionHTTPClient.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//



import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        var req = request
        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        let (data, resp): (Data, URLResponse)
        do {
            (data, resp) = try await session.data(for: req)
        } catch {
            throw APIError.transport(error)
        }
        guard let http = resp as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            let body = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, body)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func sendVoid(_ request: URLRequest) async throws {
        var req = request
        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            let body = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, body)
        }
        _ = data
    }
}
