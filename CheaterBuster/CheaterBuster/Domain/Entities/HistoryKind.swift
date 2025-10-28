//
//  HistoryKind.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import Foundation
import UIKit

public enum HistoryKind: String, Codable {
    case name   // поиск по имени
    case face   // поиск по фото
}

public struct HistoryRecord: Identifiable, Codable {
    public let id: UUID
    public let createdAt: Date
    public let kind: HistoryKind

    // name-search
    public let query: String?

    // face-search (мини-превью jpeg)
    public let imageJPEG: Data?

    // опциональные подписи для превью
    public let titlePreview: String?
    public let sourcePreview: String?

    public init(id: UUID = UUID(),
                createdAt: Date = .init(),
                kind: HistoryKind,
                query: String? = nil,
                imageJPEG: Data? = nil,
                titlePreview: String? = nil,
                sourcePreview: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.kind = kind
        self.query = query
        self.imageJPEG = imageJPEG
        self.titlePreview = titlePreview
        self.sourcePreview = sourcePreview
    }
}
