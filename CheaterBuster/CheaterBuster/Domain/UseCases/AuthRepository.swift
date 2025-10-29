//
//  AuthRepository.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation

protocol AuthRepository {
    func ensureAuthorized(apphudId: String) async throws
    var isAuthorized: Bool { get }
}

