//
//  ReverseSearchCreateResponse.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


// Domain/Models/ReverseSearchDTO.swift
import Foundation

struct ReverseSearchCreateResponse: Codable { let task_id: UUID }

struct ReverseSearchGetResponse: Codable {
    struct EnginesStatus: Codable { let google: String; let yandex: String; let bing: String }
    struct Google: Codable {
        struct VisualMatch: Codable {
            let position: Int
            let title: String
            let link: String
            let source: String
            let thumbnail: String?
        }
        let visual_matches: [VisualMatch]?
    }
    let status: EnginesStatus
    let results: Results
    struct Results: Codable {
        let google: Google?
        // yandex/bing можно добавить при необходимости UI
    }
}
