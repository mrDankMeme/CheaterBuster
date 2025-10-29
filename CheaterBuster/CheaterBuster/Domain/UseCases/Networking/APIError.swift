// Infrastructure/Networking/APIError.swift
import Foundation

enum APIError: Error {
    case invalidURL
    case http(Int, String?)
    case decoding(Error)
    case transport(Error)
    case noData
    case unauthorized
}
