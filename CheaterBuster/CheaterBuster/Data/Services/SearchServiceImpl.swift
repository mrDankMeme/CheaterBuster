//
//  SearchServiceImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class SearchServiceImpl: SearchService {
    func searchByName(_ query: String) -> AnyPublisher<[ImageHit], any Error> {
        Just(query)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .map { q in
                guard !q.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
                return (0..<3).map { i in
                    ImageHit(
                        title: "Result \(i+1) for '\(q)'",
                        source: "example.com",
                        thumbnailURL: URL(string: "https://picsum.photos/seed/\(q)\(i)/200/200") ,
                        linkURL: URL(string: "https://example.com/\(i)")
                    )
                }
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func searchByImage(_ jpegData: Data) -> AnyPublisher<[ImageHit], any Error> {
        Just((0..<3).map { i in
                  ImageHit(
                      title: "Similar \(i+1)",
                      source: "lens.example",
                      thumbnailURL: URL(string: "https://picsum.photos/seed/image\(i)/200/200"),
                      linkURL: URL(string: "https://example.com/vis\(i)")
                  )
              })
        .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    
}
