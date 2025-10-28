//
//  HistoryStore.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

public protocol HistoryStore {
    var itemsPublisher: AnyPublisher<[String],Never> { get }
    func add (_ item:String)
    func get() -> [String]
    func clear()
}
