//
//  ScreenCapture.swift
//  Ice
//

import AppKit
import CoreGraphics
import OSLog
import ScreenCaptureKit

/// A namespace for screen capture operations.
enum ScreenCapture {
    private static let logger = Logger(category: "ScreenCapture")

    // MARK: Permissions

    /// Returns a Boolean value that indicates whether the app has screen
    /// capture permissions.
    static func checkPermissions() -> Bool {
        // Prefer the system preflight check. Inspecting window metadata remains
        // useful as a fallback on systems where preflight has not refreshed yet.
        if CGPreflightScreenCaptureAccess() {
            return true
        }

        return Bridging.getMenuBarWindowList(option: [.itemsOnly, .activeSpace])
            .compactMap { WindowInfo(windowID: $0) }
            .filter { $0.owningApplication != .current }
            .contains { $0.title != nil }
    }

    /// Returns a Boolean value that indicates whether the app has screen
    /// capture permissions.
    ///
    /// This function caches its initial result and returns it on subsequent
    /// calls. Pass `true` to the `reset` parameter to replace the cached
    /// result with a newly computed value.
    static func cachedCheckPermissions(reset: Bool = false) -> Bool {
        enum Context {
            static var cachedResult: Bool?
        }
        if !reset, let result = Context.cachedResult {
            return result
        }
        let result = checkPermissions()
        Context.cachedResult = result
        return result
    }

    /// Requests screen capture permissions.
    static func requestPermissions() {
        if #available(macOS 26.0, *) {
            // Glace is an LSUIElement app without a Dock icon. On macOS 26 and
            // later, TCC only registers the request reliably when the app is
            // frontmost, so activate before calling the dedicated API.
            NSApp.activate(ignoringOtherApps: true)

            // CoreGraphics creates the TCC entry. Keep ScreenCaptureKit as a
            // fallback prompt trigger because behavior differs across macOS 26
            // and 27 builds.
            let granted = CGRequestScreenCaptureAccess()
            logger.debug("CoreGraphics screen capture request result: \(granted)")
            SCShareableContent.getWithCompletionHandler { _, error in
                if let error {
                    logger.debug("ScreenCaptureKit permission request failed: \(error)")
                } else {
                    logger.debug("ScreenCaptureKit permission request completed")
                }
            }
        } else if #available(macOS 15.0, *) {
            // CGRequestScreenCaptureAccess() is broken on macOS 15. We can
            // try accessing SCShareableContent to trigger a request if the
            // user doesn't have permissions.
            SCShareableContent.getWithCompletionHandler { _, _ in }
        } else {
            CGRequestScreenCaptureAccess()
        }
    }

    // MARK: Capture Window(s)

    /// Captures a composite image of an array of windows.
    ///
    /// The windows are composited from front to back, according to the order
    /// of the `windowIDs` parameter.
    ///
    /// - Parameters:
    ///   - windowIDs: The identifiers of the windows to capture.
    ///   - screenBounds: The bounds to capture, specified in screen coordinates.
    ///     Pass `nil` to capture the minimum rectangle that encloses the windows.
    ///   - option: Options that specify which parts of the windows are captured.
    static func captureWindows(with windowIDs: [CGWindowID], screenBounds: CGRect? = nil, option: CGWindowImageOption = []) -> CGImage? {
        guard let array = Bridging.createCGWindowArray(with: windowIDs) else {
            return nil
        }
        let bounds = screenBounds ?? .null
        // ScreenCaptureKit doesn't support capturing images of offscreen menu bar
        // items, so we unfortunately have to use the deprecated CGWindowList API.
        return CGImage(windowListFromArrayScreenBounds: bounds, windowArray: array, imageOption: option)
    }

    /// Captures an image of a window.
    ///
    /// - Parameters:
    ///   - windowID: The identifier of the window to capture.
    ///   - screenBounds: The bounds to capture, specified in screen coordinates.
    ///     Pass `nil` to capture the minimum rectangle that encloses the window.
    ///   - option: Options that specify which parts of the window are captured.
    static func captureWindow(with windowID: CGWindowID, screenBounds: CGRect? = nil, option: CGWindowImageOption = []) -> CGImage? {
        captureWindows(with: [windowID], screenBounds: screenBounds, option: option)
    }
}
