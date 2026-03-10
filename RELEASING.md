# Releasing Glace

`Glace` uses Sparkle for in-app updates. A release is only usable by Sparkle when all of the following are published together:

- a signed `.dmg`
- a notarized `.dmg`
- an `appcast.xml`
- a Sparkle EdDSA signature generated from the private key matching `SUPublicEDKey`

The GitHub Actions workflow in `.github/workflows/release.yml` handles this on every GitHub release publication.

## Required repository secrets

- `MACOS_CERTIFICATE_P12_BASE64`: base64-encoded Developer ID Application certificate (`.p12`)
- `MACOS_CERTIFICATE_PASSWORD`: password for the `.p12`
- `MACOS_KEYCHAIN_PASSWORD`: temporary keychain password used on the runner
- `APPLE_ID`: Apple account email used for notarization
- `APPLE_APP_SPECIFIC_PASSWORD`: app-specific password for notarization
- `APPLE_TEAM_ID`: Apple Developer team identifier
- `SPARKLE_PRIVATE_KEY`: Sparkle private EdDSA key matching `SUPublicEDKey` in `Ice/Info.plist`

## GitHub setup

- Enable GitHub Pages for this repository.
- Publish Pages from the `gh-pages` branch.
- Create a GitHub release to trigger the workflow.
- Use a release tag like `v0.11.13` or `0.11.13`. The workflow derives `MARKETING_VERSION` from the tag and uses the GitHub Actions run number as `CFBundleVersion`.

The workflow will:

1. archive and export the signed app
2. package it as `Glace-<version>.dmg`
3. notarize and staple the `.dmg`
4. generate release notes HTML and `appcast.xml`
5. push update metadata to `gh-pages`
6. upload the `.dmg` as a GitHub release asset
