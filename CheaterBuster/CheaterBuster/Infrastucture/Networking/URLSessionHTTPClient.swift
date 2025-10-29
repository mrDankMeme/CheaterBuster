//
//  URLSessionHTTPClient.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


// Data/API/URLSessionHTTPClient.swift
import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch { throw APIError.transport(error) }

        guard let http = response as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8))
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch { throw APIError.decoding(error) }
    }

    func sendVoid(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw APIError.unauthorized }
            throw APIError.http(http.statusCode, String(data: data, encoding: .utf8))
        }
        _ = data
    }
}
