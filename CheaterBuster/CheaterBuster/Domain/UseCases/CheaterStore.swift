//
//  CheaterStore.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//


import Foundation

protocol CheaterStore {
    func load() -> [CheaterRecord]
    func add(_ record: CheaterRecord)
    func clearAll()
}
