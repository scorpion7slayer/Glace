//
//  MenuBarItemDiscovery.swift
//  Ice
//

import Cocoa
import OSLog

/// A read-only representation of a status item hosted by macOS 27.
struct MenuBarItemSnapshot: Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let bundleIdentifier: String
    let bounds: CGRect
    let isSystemItem: Bool
}

enum MenuBarItemDiscoveryState: Equatable {
    case loading
    case available
    case permissionRequired
    case unavailable
}

/// Discovers menu bar items through Accessibility on macOS 27.
///
/// GoldenGate hosts status items inside MenuBarAgent instead of exposing one
/// WindowServer window per item. The existing movement backend therefore
/// cannot safely rearrange those items, but Accessibility still gives Glace a
/// truthful, non-blocking view of the items that macOS currently publishes.
@available(macOS 27.0, *)
enum MenuBarItemDiscovery {
    private static let logger = Logger(category: "MenuBarItemDiscovery")
    private static let maximumItemHeight: CGFloat = 40

    private struct RawItem {
        let bundleIdentifier: String
        let appName: String
        let itemName: String
        let stableName: String
        let bounds: CGRect
    }

    static func discover() -> [MenuBarItemSnapshot] {
        guard AXHelpers.isProcessTrusted() else {
            logger.warning("Accessibility permission is missing")
            return []
        }

        let ownBundleIdentifier = Bundle.main.bundleIdentifier
        var rawItems = [RawItem]()

        for runningApplication in NSWorkspace.shared.runningApplications {
            guard
                let application = AXHelpers.application(for: runningApplication),
                let extrasMenuBar = AXHelpers.extrasMenuBar(for: application)
            else {
                continue
            }

            let bundleIdentifier = runningApplication.bundleIdentifier
                ?? runningApplication.localizedName
                ?? "pid.\(runningApplication.processIdentifier)"
            let appName = runningApplication.localizedName ?? bundleIdentifier

            for (index, child) in AXHelpers.children(for: extrasMenuBar).enumerated() {
                guard
                    let frame = AXHelpers.frame(for: child),
                    frame.width > 0,
                    frame.height > 0,
                    frame.height <= maximumItemHeight
                else {
                    continue
                }

                let nestedChildren = AXHelpers.children(for: child)
                let identifier = AXHelpers.identifier(for: child).nonEmpty
                    ?? nestedChildren.lazy.compactMap { AXHelpers.identifier(for: $0).nonEmpty }.first
                let accessibilityDescription = AXHelpers.description(for: child).nonEmpty
                    ?? nestedChildren.lazy.compactMap { AXHelpers.description(for: $0).nonEmpty }.first
                let title = AXHelpers.title(for: child).nonEmpty
                let stableName = identifier ?? accessibilityDescription ?? title ?? "Item-\(index)"

                // Glace's divider status items are implementation details, not apps
                // the user can manage in the native macOS 27 overflow interface.
                if bundleIdentifier == ownBundleIdentifier,
                   stableName.hasPrefix("Ice.ControlItem.")
                {
                    continue
                }

                // The double-chevron is the system overflow affordance itself.
                let normalizedName = stableName.lowercased()
                if bundleIdentifier == "com.apple.MenuBarAgent",
                   normalizedName.contains("overflow")
                {
                    continue
                }

                rawItems.append(
                    RawItem(
                        bundleIdentifier: bundleIdentifier,
                        appName: appName,
                        itemName: title ?? accessibilityDescription ?? identifier ?? appName,
                        stableName: stableName,
                        bounds: frame
                    )
                )
            }
        }

        let itemCountByBundle = Dictionary(grouping: rawItems, by: \.bundleIdentifier)
            .mapValues(\.count)
        var occurrenceByIdentity = [String: Int]()

        return rawItems
            .sorted {
                if abs($0.bounds.midY - $1.bounds.midY) > 4 {
                    return $0.bounds.midY < $1.bounds.midY
                }
                return $0.bounds.minX < $1.bounds.minX
            }
            .map { item in
                let identity = "\(item.bundleIdentifier):\(item.stableName)"
                let occurrence = occurrenceByIdentity[identity, default: 0]
                occurrenceByIdentity[identity] = occurrence + 1
                let displayName = if itemCountByBundle[item.bundleIdentifier, default: 0] > 1 {
                    "\(item.appName) — \(item.itemName)"
                } else {
                    item.appName
                }

                return MenuBarItemSnapshot(
                    id: "\(identity):\(occurrence)",
                    displayName: displayName,
                    bundleIdentifier: item.bundleIdentifier,
                    bounds: item.bounds,
                    isSystemItem: item.bundleIdentifier.hasPrefix("com.apple.")
                )
            }
    }
}

private extension Optional where Wrapped == String {
    var nonEmpty: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
