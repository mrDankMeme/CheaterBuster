//
//  CheaterRecord.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//



import Foundation

public struct CheaterRecord: Identifiable, Hashable, Codable {
    public enum Kind: String, Codable { case image, file, text }

    public let id: UUID
    public let date: Date
    public let kind: Kind
    public let riskScore: Int
    public let note: String?
    public let redFlags: [String]
    public let recommendations: [String]

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        kind: Kind,
        riskScore: Int,
        note: String? = nil,
        redFlags: [String],
        recommendations: [String]
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.riskScore = riskScore
        self.note = note
        self.redFlags = redFlags
        self.recommendations = recommendations
    }

    // Hashable/Equatable — только по id (удобно для навигации/списков)
    public static func == (lhs: CheaterRecord, rhs: CheaterRecord) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
