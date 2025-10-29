//
//  MultipartFormData.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


// сборщик multipart-запросов

import Foundation

struct MultipartFormData {
    struct FilePart {
        let name: String
        let filename: String
        let mimeType: String
        let data: Data
    }
    
    private let boundary = "----CB-\(UUID().uuidString)"
    var contentType: String { "multipart/form-data; boundary=\(boundary)" }
    
    func build(fields: [String: String?], files: [FilePart]) -> Data {
        var body = Data()
        for (k,v) in fields { guard let v else { continue }
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n")
            body.append("\(v)\r\n")
        }
        for f in files {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(f.name)\"; filename=\"\(f.filename)\"\r\n")
            body.append("Content-Type: \(f.mimeType)\r\n\r\n")
            body.append(f.data); body.append("\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
}
private extension Data {
    mutating func append(_ s: String) {
        if let d = s.data(using: .utf8) {
            append(d)
        }
    }
}
