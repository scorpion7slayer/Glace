//
//  PermissionsManager.swift
//  Ice
//

import Combine
import Foundation

/// A type that manages the permissions of the app.
@MainActor
final class PermissionsManager: ObservableObject {
    /// The state of the granted permissions for the app.
    enum PermissionsState {
        case missingPermissions
        case hasAllPermissions
        case hasRequiredPermissions
    }

    /// The state of the granted permissions for the app.
    @Published var permissionsState = PermissionsState.missingPermissions

    let accessibilityPermission: AccessibilityPermission

    let screenRecordingPermission: ScreenRecordingPermission

    let allPermissions: [Permission]

    private(set) weak var appState: AppState?

    private var cancellables = Set<AnyCancellable>()

    var requiredPermissions: [Permission] {
        allPermissions.filter { $0.isRequired }
    }

    init(appState: AppState) {
        self.appState = appState
        self.accessibilityPermission = AccessibilityPermission()
        self.screenRecordingPermission = ScreenRecordingPermission()
        self.allPermissions = [
            accessibilityPermission,
            screenRecordingPermission,
        ]
        configureCancellables()
        updatePermissionsState()
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        Publishers.Merge(
            accessibilityPermission.$hasPermission.mapToVoid(),
            screenRecordingPermission.$hasPermission.mapToVoid()
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.updatePermissionsState()
        }
        .store(in: &c)

        cancellables = c
    }

    private func updatePermissionsState() {
        if allPermissions.allSatisfy({ $0.hasPermission }) {
            permissionsState = .hasAllPermissions
        } else if requiredPermissions.allSatisfy({ $0.hasPermission }) {
            permissionsState = .hasRequiredPermissions
        } else {
            permissionsState = .missingPermissions
        }
    }

    /// Starts running all permission checks.
    func startAllChecks() {
        for permission in allPermissions {
            permission.startCheck()
        }
        updatePermissionsState()
    }

    /// Stops running all permissions checks.
    func stopAllChecks() {
        for permission in allPermissions {
            permission.stopCheck()
        }
        for permission in allPermissions {
            permission.refreshPermissionState()
        }
        updatePermissionsState()
    }
}
