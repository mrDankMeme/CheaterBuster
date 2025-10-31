//
//  PermissionsManagerImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//



import Foundation
import AppTrackingTransparency   // MARK: - Added
import AdSupport                 // MARK: - Added
import Photos                    // MARK: - Added
import AVFoundation              // MARK: - Added
import UserNotifications         // MARK: - Added

final class PermissionsManagerImpl: PermissionsManager {

    // MARK: - Status

    func status(of permission: Permission) async -> PermissionStatus {
        switch permission {
        case .tracking:
            if #available(iOS 14, *) {
                switch ATTrackingManager.trackingAuthorizationStatus {
                case .authorized:   return .authorized
                case .denied:       return .denied
                case .restricted:   return .restricted
                case .notDetermined:return .notDetermined
                @unknown default:   return .temporarilyUnavailable
                }
            } else {
                return .unsupported
            }

        case .notifications:
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral: return .authorized
            case .denied:       return .denied
            case .notDetermined:return .notDetermined
            @unknown default:   return .temporarilyUnavailable
            }

        case .photoLibrary:
            let s = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch s {
            case .authorized, .limited: return .authorized
            case .denied:       return .denied
            case .restricted:   return .restricted
            case .notDetermined:return .notDetermined
            @unknown default:   return .temporarilyUnavailable
            }

        case .camera:
            let s = AVCaptureDevice.authorizationStatus(for: .video)
            switch s {
            case .authorized:   return .authorized
            case .denied:       return .denied
            case .restricted:   return .restricted
            case .notDetermined:return .notDetermined
            @unknown default:   return .temporarilyUnavailable
            }

        case .files:
            // На iOS доступ к файлам идёт через UIDocumentPicker (пермишна нет).
            return .authorized
        }
    }

    // MARK: - Request

    func request(_ permission: Permission) async -> PermissionStatus {
        switch permission {
        case .tracking:
            if #available(iOS 14, *) {
                let current = await status(of: .tracking)
                if current != .notDetermined { return current }
                let result = await withCheckedContinuation { (continuation: CheckedContinuation<PermissionStatus, Never>) in
                    ATTrackingManager.requestTrackingAuthorization { status in
                        switch status {
                        case .authorized:   continuation.resume(returning: .authorized)
                        case .denied:       continuation.resume(returning: .denied)
                        case .restricted:   continuation.resume(returning: .restricted)
                        case .notDetermined:continuation.resume(returning: .notDetermined)
                        @unknown default:   continuation.resume(returning: .temporarilyUnavailable)
                        }
                    }
                }
                _ = ASIdentifierManager.shared().advertisingIdentifier // «пробуждение» фреймворка
                return result
            } else {
                return .unsupported
            }

        case .notifications:
            let current = await status(of: .notifications)
            if current != .notDetermined { return current }
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                return granted ? .authorized : .denied
            } catch {
                return .temporarilyUnavailable
            }

        case .photoLibrary:
            let current = await status(of: .photoLibrary)
            if current != .notDetermined { return current }
            return await withCheckedContinuation { (continuation: CheckedContinuation<PermissionStatus, Never>) in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { s in
                    switch s {
                    case .authorized, .limited: continuation.resume(returning: .authorized)
                    case .denied:       continuation.resume(returning: .denied)
                    case .restricted:   continuation.resume(returning: .restricted)
                    case .notDetermined:continuation.resume(returning: .notDetermined)
                    @unknown default:   continuation.resume(returning: .temporarilyUnavailable)
                    }
                }
            }

        case .camera:
            let current = await status(of: .camera)
            if current != .notDetermined { return current }
            let granted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
            return granted ? .authorized : .denied

        case .files:
            // Пермишна нет, считаем доступ разрешён (UIDocumentPicker сам покажет системный UI).
            return .authorized
        }
    }
}
