//
//  CheaterRecord.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import Foundation
import UIKit

public enum CheaterSourceKind: String, Codable {
    case image   // анализ скриншота/фото
    case file    // анализ документа/файла
}

public struct CheaterRecord: Identifiable, Codable {
    public let id: UUID
    public let createdAt: Date
    public let kind: CheaterSourceKind
    public let riskScore: Int            // 0...100
    public let previewJPEG: Data?        // маленькая превьюшка (опц.)

    // опционально — краткий заголовок/примечание
    public let note: String?

    public init(id: UUID = UUID(),
                createdAt: Date = .init(),
                kind: CheaterSourceKind,
                riskScore: Int,
                previewJPEG: Data? = nil,
                note: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.riskScore = max(0, min(100, riskScore))
        self.previewJPEG = previewJPEG
        self.note = note
    }
}
