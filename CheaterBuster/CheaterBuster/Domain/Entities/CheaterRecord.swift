//
//  CheaterRecord.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import Foundation

struct CheaterRecord: Identifiable, Codable {
    enum Kind: String, Codable { case image, file, text }
    let id: UUID
    let date: Date
    let kind: Kind
    let riskScore: Int
    let note: String?                 // делаем опциональным (UI у тебя так использует)
    let redFlags: [String]
    let recommendations: [String]

    init(id: UUID = UUID(),
         date: Date = .init(),
         kind: Kind,
         riskScore: Int,
         note: String?,
         redFlags: [String],
         recommendations: [String]) {
        self.id = id
        self.date = date
        self.kind = kind
        self.riskScore = riskScore
        self.note = note
        self.redFlags = redFlags
        self.recommendations = recommendations
    }
}
