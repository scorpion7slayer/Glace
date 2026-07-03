//
//  MenuBarLayoutSettingsPane.swift
//  Ice
//

import AppKit
import SwiftUI

struct MenuBarLayoutSettingsPane: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var itemManager: MenuBarItemManager

    private var hasItems: Bool {
        !itemManager.itemCache.managedItems.isEmpty
    }

    var body: some View {
        if #available(macOS 27.0, *) {
            systemManagedLayout
        } else if !ScreenCapture.cachedCheckPermissions() {
            missingScreenRecordingPermissions
        } else if appState.menuBarManager.isMenuBarHiddenBySystemUserDefaults {
            cannotArrange
        } else {
            IceForm(spacing: 20) {
                header
                layoutBars
            }
        }
    }

    @available(macOS 27.0, *)
    private var systemManagedLayout: some View {
        IceForm(alignment: .leading, spacing: 20) {
            IceSection(options: [.isBordered]) {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Menu bar overflow is managed by macOS 27", systemImage: "chevron.left.2")
                        .font(.title3.bold())

                    Text("GoldenGate groups extra menu bar items behind the double arrow. Glace detects the items with Accessibility, but macOS no longer allows the legacy divider and drag system to move them safely.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Apps add their own menu bar items. Choose which system items appear from Menu Bar settings, and use the double arrow to access overflow items.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Button("Open Menu Bar Settings", systemImage: "gear") {
                            openMenuBarSettings()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Refresh", systemImage: "arrow.clockwise") {
                            Task {
                                await itemManager.cacheItemsRegardless()
                            }
                        }
                    }
                }
            }

            IceSection("Detected Menu Bar Items", options: [.isBordered, .hasDividers]) {
                discoveredItems
            }
        }
    }

    @available(macOS 27.0, *)
    @ViewBuilder
    private var discoveredItems: some View {
        switch itemManager.discoveryState {
        case .loading:
            HStack(spacing: 10) {
                ProgressView()
                    .controlSize(.small)
                Text("Detecting menu bar items…")
                    .foregroundStyle(.secondary)
            }
        case .permissionRequired:
            VStack(alignment: .leading, spacing: 10) {
                Label("Accessibility permission is required to detect menu bar items.", systemImage: "hand.raised")
                Button("Open Accessibility Settings") {
                    appState.permissions.accessibility.performRequest()
                }
            }
        case .unavailable:
            ContentUnavailableView(
                "No Menu Bar Items Detected",
                systemImage: "menubar.rectangle",
                description: Text("Glace could not read MenuBarAgent yet. Try refreshing after the menu bar finishes updating.")
            )
        case .available:
            ForEach(itemManager.systemManagedItems) { item in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: item.displayName)
                        Text(verbatim: item.bundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                } icon: {
                    Image(systemName: item.isSystemItem ? "apple.logo" : "app.dashed")
                        .symbolRenderingMode(.monochrome)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func openMenuBarSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.ControlCenter-Settings.extension") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @ViewBuilder
    private var header: some View {
        IceSection {
            VStack(spacing: 3) {
                Text("Drag to arrange your menu bar items into different sections.")
                    .font(.title3.bold())
                Text("Items can also be arranged by ⌘ Command + dragging them in the menu bar.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(15)
        }
    }

    @ViewBuilder
    private var layoutBars: some View {
        VStack(spacing: 20) {
            ForEach(MenuBarSection.Name.allCases, id: \.self) { section in
                layoutBar(for: section)
            }
        }
        .opacity(hasItems ? 1 : 0.75)
        .blur(radius: hasItems ? 0 : 5)
        .allowsHitTesting(hasItems)
        .overlay {
            if !hasItems {
                loadingMenuBarItems
            }
        }
    }

    @ViewBuilder
    private var cannotArrange: some View {
        Text("Glace cannot arrange menu bar items in automatically hidden menu bars.")
            .font(.title3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var missingScreenRecordingPermissions: some View {
        VStack {
            Text("Menu bar layout requires screen recording permissions.")
                .font(.title2)

            Button {
                appState.navigationState.settingsNavigationIdentifier = .advanced
            } label: {
                Text("Go to Advanced Settings")
            }
            .buttonStyle(.link)
        }
    }

    @ViewBuilder
    private var loadingMenuBarItems: some View {
        VStack {
            Text("Loading menu bar items…")
            ProgressView()
        }
        .font(.title)
    }

    @ViewBuilder
    private func layoutBar(for name: MenuBarSection.Name) -> some View {
        if
            let section = appState.menuBarManager.section(withName: name),
            section.isEnabled
        {
            VStack(alignment: .leading) {
                Text(name.localized)
                    .font(.headline)
                    .padding(.leading, 8)

                LayoutBar(imageCache: appState.imageCache, section: name)
            }
        }
    }
}
