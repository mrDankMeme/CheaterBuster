//
//  PermissionsManager.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//




import Foundation

public protocol PermissionsManager {
    func status(of permission: Permission) async -> PermissionStatus
    func request(_ permission: Permission) async -> PermissionStatus
}

public enum Permission: Sendable {
    case tracking
    case notifications
    case photoLibrary
    case camera
    case files // документ-пикер (на iOS отдельного пермишна нет, см. реализацию)
}

public enum PermissionStatus: Equatable, Sendable {
    case authorized
    case denied
    case notDetermined
    case restricted
    case temporarilyUnavailable  // сеть/система не готова
    case unsupported             // платформа не поддерживает
}
