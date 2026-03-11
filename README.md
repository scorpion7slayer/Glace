<div align="center">
  <img src="Ice/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="180" height="180" alt="Glace icon">
  <h1>Glace</h1>
  <p><strong>A macOS menu bar manager focused on clarity, customization, and low overhead.</strong></p>
</div>

> **This is a personal fork of [Ice](https://github.com/jordanbaird/Ice)** by Jordan Baird.
> Glace keeps the core idea of Ice while introducing its own branding, release pipeline, fixes, and behavior changes.

[![Platform](https://img.shields.io/badge/platform-macOS-blue?style=flat-square)](https://www.apple.com/macos/)
[![Requirements](https://img.shields.io/badge/requirements-macOS%2014%2B-fa4e49?style=flat-square)](https://www.apple.com/macos/)
[![Download](https://img.shields.io/badge/download-latest-brightgreen?style=flat-square)](https://github.com/scorpion7slayer/Glace/releases/latest)
[![License](https://img.shields.io/github/license/scorpion7slayer/Glace?style=flat-square)](LICENSE)

## Custom Additions

### Rebranding

- **Full Ice to Glace rebrand** across the app name, display name, settings UI, About screen, and release flow
- **Custom ice cream identity** with a new app icon and a dedicated Glace menu bar icon style
- **Fork-specific update pipeline** wired to the `scorpion7slayer/Glace` repository instead of the original Ice infrastructure

### Glace Bar and Interaction Fixes

- **Stability fixes for Glace Bar** when opening hidden menu bar items from the control icon
- **Improved hidden item rendering** so the separate bar reliably shows the correct menu bar item icons
- **Safer menu bar item tracking** using stable window IDs instead of weaker item metadata matches
- **Better temporary item handling** when clicking hidden menu bar items or moving them between sections

### Permissions and App Behavior

- **Independent app identity** with its own bundle identifier for cleaner macOS permission handling
- **Settings window persistence improvements** so clicking outside the settings window does not immediately dismiss it
- **Clearer About page credits** showing Glace as a fork of Ice and crediting Jordan Baird

### Performance Work

- **Reduced idle CPU work** by avoiding unnecessary menu bar scans when Glace UI is not active
- **Lower memory usage** by clearing image caches when Glace Bar, search, and layout UI are not visible
- **Less background polling** for permissions, overlay refreshes, and menu bar color/image capture

---

Glace helps you organize and customize the macOS menu bar.

Its main job is still the same as Ice: letting you hide, show, and rearrange menu bar items. On top of that, Glace includes a separate hidden-items bar, menu bar appearance tools, search, hotkeys, and release automation tailored for this fork.

## What Glace Does

1. **Separates** visible, hidden, and always-hidden menu bar items
2. **Lets you reveal** hidden items by click, hover, scroll, hotkeys, or Glace Bar
3. **Provides tools** to rearrange menu bar items visually
4. **Customizes** menu bar appearance with tint, border, shadow, and shape options
5. **Keeps the app lightweight** by reducing unnecessary background work whenever possible

## Quick Start

### Installation

1. Download the latest release from the [releases page](https://github.com/scorpion7slayer/Glace/releases/latest)
2. Move `Glace.app` into `/Applications`
3. Launch Glace
4. Grant the required macOS permissions
5. Open Settings and configure your preferred menu bar layout

### Required Permissions

Glace may request:

- **Accessibility** for real-time menu bar inspection and item management
- **Screen Recording** for menu bar appearance editing and item image capture

Without Screen Recording, Glace can still work in a more limited mode.

## Features

### Menu Bar Management

- Hide menu bar items
- Separate **hidden** and **always-hidden** sections
- Show hidden items on click, hover, or scroll
- Automatically rehide shown items
- Search menu bar items
- Display hidden items in a dedicated **Glace Bar**
- Drag and drop menu bar items in the layout editor
- Adjust menu bar item spacing

### Appearance

- Menu bar tint
- Menu bar border
- Menu bar shadow
- Rounded and split menu bar shapes
- Overlay-based appearance editing tools

### Hotkeys and Utility

- Toggle menu bar sections
- Toggle Glace Bar
- Open menu bar item search
- Launch at login
- Sparkle-based app updates for release builds

## Current Focus

Glace is an actively maintained fork, with current work focused on:

- reliability of hidden item rendering
- release and update infrastructure
- lowering idle CPU and RAM usage
- keeping the fork independent from upstream Ice branding and distribution

## Development

Glace is a native macOS app built with SwiftUI and AppKit integration.

### Local Build

Open the project in Xcode and run the `Ice` scheme, or build from the command line:

```bash
xcodebuild -project Ice.xcodeproj -scheme Ice -configuration Debug build
```

### Release Flow

Tagged releases are built through GitHub Actions and published with Sparkle metadata for in-app updates.

For release setup details, secrets, signing, notarization, and appcast publishing, see [RELEASING.md](RELEASING.md).

## Why macOS 14+?

Glace depends on modern macOS APIs used for menu bar inspection, screen capture, and system integration. Because of that, this fork targets **macOS 14 and later**.

## Credits

- **Original project:** [Ice](https://github.com/jordanbaird/Ice)
- **Original author:** [Jordan Baird](https://github.com/jordanbaird)
- **Fork / Glace maintenance:** [scorpion7slayer](https://github.com/scorpion7slayer)

## License

Glace is distributed under the [GPL-3.0 license](LICENSE).
