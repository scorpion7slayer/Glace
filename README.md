<div align="center">
  <img src="Ice/Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width="180" height="180" alt="Glace icon">
  <h1>Glace</h1>
  <p><strong>A native macOS menu bar manager focused on reliability, customization, and low overhead.</strong></p>
</div>

> Glace is an independent fork of [Ice](https://github.com/jordanbaird/Ice) by Jordan Baird. It keeps the core menu bar workflow while maintaining its own identity, fixes, release pipeline, and platform compatibility work.

[![Platform](https://img.shields.io/badge/platform-macOS-blue?style=flat-square)](https://www.apple.com/macos/)
[![Requirements](https://img.shields.io/badge/requirements-macOS%2014%2B-fa4e49?style=flat-square)](https://www.apple.com/macos/)
[![Download](https://img.shields.io/badge/download-latest-brightgreen?style=flat-square)](https://github.com/scorpion7slayer/Glace/releases/latest)
[![License](https://img.shields.io/github/license/scorpion7slayer/Glace?style=flat-square)](LICENSE)

## Highlights

- Hide, reveal, search, and rearrange menu bar items.
- Separate hidden and always-hidden sections.
- Display hidden items in the dedicated Glace Bar.
- Customize menu bar tint, border, shadow, and shape.
- Trigger actions with clicks, scrolling, hovering, and hotkeys.
- Adjust menu bar item spacing.
- Update securely through the Glace Sparkle feed.

## macOS compatibility

Glace 0.12.0 incorporates Ice's macOS 26 Tahoe architecture updates, including its redesigned menu bar item discovery, event monitoring, XPC-backed source lookup, capture handling, and Tahoe-specific UI behavior.

The project also builds and launches with Xcode 27 and the macOS 27 SDK on macOS 27 GoldenGate. GoldenGate no longer exposes individual status items as WindowServer windows, so Glace uses Accessibility to detect the items published by `MenuBarAgent` and presents the native macOS overflow workflow instead of leaving the layout editor in an endless loading state. Legacy divider-based drag management remains available through macOS 26.

Settings use the system Liquid Glass material on macOS 26 and later, with the existing adaptive appearance retained on older supported releases. English is the source and fallback language; French is included and follows the user's macOS language preference.

Swift dependencies have been updated for the SDK 27 toolchain, including CompactSlider 2.1 and Sparkle 2.9.4. The deployment target remains macOS 14, so Sonoma and later remain supported.

Because macOS 27 and Xcode 27 are prerelease software, later Apple betas may still require follow-up adjustments.

## Installation

1. Download the latest release from the [releases page](https://github.com/scorpion7slayer/Glace/releases/latest).
2. Move `Glace.app` into `/Applications`.
3. Launch Glace and grant the requested permissions.

Glace uses Accessibility for menu bar inspection and item management. Screen Recording is needed for menu bar appearance editing and item image capture; without it, some visual features are limited.

## Development

The project uses SwiftUI and AppKit and requires Xcode. Build, launch, and verify the local app with:

```bash
./script/build_and_run.sh --verify
```

The script automatically prefers `/Applications/Xcode-beta.app` when present, then falls back to stable Xcode. It also supports `--debug`, `--logs`, and `--telemetry`.

For release signing, notarization, and Sparkle publication details, see [RELEASING.md](RELEASING.md).

## Credits

- Original project: [Ice](https://github.com/jordanbaird/Ice)
- Original author: [Jordan Baird](https://github.com/jordanbaird)
- Glace maintenance: [scorpion7slayer](https://github.com/scorpion7slayer)

## License

Glace is distributed under the [GPL-3.0 license](LICENSE).
