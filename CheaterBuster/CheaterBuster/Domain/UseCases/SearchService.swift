//
//  SearchService.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Combine
import Foundation

public protocol SearchService {
    func searchByName(_ query: String) -> AnyPublisher<[ImageHit], Error>
    func searchByImage(_ jpegData: Data) -> AnyPublisher<[ImageHit],Error>
}
