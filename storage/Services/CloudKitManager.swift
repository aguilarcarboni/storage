//
//  CloudKitManager.swift
//  media
//
//  Created by Andrés on 28/6/2025.
//

import Foundation
import CloudKit
import SwiftUI
import Combine

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var isCloudKitAvailable = false
    @Published var isSignedInToiCloud = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var error: Error?
    
    private let container = CKContainer(identifier: "iCloud.com.aguilarcarboni.media")
    private var cancellables = Set<AnyCancellable>()
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(Error)
        
        var description: String {
            switch self {
            case .idle:
                return "Ready"
            case .syncing:
                return "Syncing..."
            case .success:
                return "Synced"
            case .error(let error):
                return "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private init() {
        checkCloudKitAvailability()
        setupNotifications()
    }
    
    // MARK: - CloudKit Availability
    
    private func checkCloudKitAvailability() {
        container.accountStatus { [weak self] accountStatus, error in
            DispatchQueue.main.async {
                self?.isCloudKitAvailable = (accountStatus == .available)
                self?.isSignedInToiCloud = (accountStatus == .available)
                
                if let error = error {
                    self?.error = error
                    self?.syncStatus = .error(error)
                }
            }
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .CKAccountChanged)
            .sink { [weak self] _ in
                self?.checkCloudKitAvailability()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sync Status
    
    func updateSyncStatus(_ status: SyncStatus) {
        syncStatus = status
        
        if case .success = status {
            lastSyncDate = Date()
        }
    }
    
    // MARK: - CloudKit Operations
    
    func requestCloudKitPermissions() async throws {
        let status = try await container.requestApplicationPermission(.userDiscoverability)
        if status != .granted {
            throw CloudKitError.permissionDenied
        }
    }
    
    func checkCloudKitStatus() async -> Bool {
        do {
            let accountStatus = try await container.accountStatus()
            await MainActor.run {
                self.isCloudKitAvailable = (accountStatus == .available)
                self.isSignedInToiCloud = (accountStatus == .available)
            }
            return accountStatus == .available
        } catch {
            await MainActor.run {
                self.error = error
                self.syncStatus = .error(error)
            }
            return false
        }
    }
    
    // MARK: - Manual Sync
    
    func forceSyncNow() async {
        await MainActor.run {
            syncStatus = .syncing
        }
        
        // This is a placeholder for manual sync operations
        // SwiftData with CloudKit handles sync automatically
        // but you can implement manual operations here if needed
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        await MainActor.run {
            syncStatus = .success
            lastSyncDate = Date()
        }
    }
}

// MARK: - CloudKit Errors

enum CloudKitError: LocalizedError {
    case permissionDenied
    case notSignedIn
    case networkUnavailable
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "CloudKit permission denied"
        case .notSignedIn:
            return "Not signed in to iCloud"
        case .networkUnavailable:
            return "Network unavailable"
        case .quotaExceeded:
            return "iCloud storage quota exceeded"
        }
    }
}

// MARK: - View Extensions

extension View {
    func cloudKitStatusAlert() -> some View {
        self.alert("CloudKit Status", isPresented: .constant(CloudKitManager.shared.error != nil)) {
            Button("OK") {
                CloudKitManager.shared.error = nil
            }
        } message: {
            if let error = CloudKitManager.shared.error {
                Text(error.localizedDescription)
            }
        }
    }
} 