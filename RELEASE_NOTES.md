# Glace 2.0

Glace 2.0 is a compatibility and reliability release for modern macOS.

## What’s new

- Added native support for macOS 26 Tahoe and compatibility behavior for macOS 27 GoldenGate.
- Added an English and French language selector. English remains the default.
- Added Liquid Glass styling where supported by macOS.
- Replaced the broken GoldenGate reveal animation with a native context menu on the Glace status item.
- Restored the Glace application menu next to the Apple menu.
- Reworked menu bar item discovery so the layout page no longer loads forever.
- Added clear GoldenGate explanations for controls that macOS now manages itself.
- Corrected the Glace melting ice-cream application icon.
- Added a dedicated Glace website, release notes, security policy, and signed release workflow.

## Permissions and identity

The app uses the `com.theo.Glace` identity and is signed by the Glace maintainer’s Developer ID certificate. Accessibility and Screen Recording permissions are requested by Glace itself rather than by Ice, Thaw, or another fork.

## Compatibility

- macOS 26 Tahoe keeps Glace’s classic hide, reveal, search, spacing, and layout controls.
- macOS 27 GoldenGate uses Apple’s system-managed double arrow for hidden item placement. Glace provides detection, appearance overlays, and native menu actions without fighting the system behavior.

## Open source

Glace remains a fork of [Ice by Jordan Baird](https://github.com/jordanbaird/Ice) and includes attribution for every bundled open-source dependency.
