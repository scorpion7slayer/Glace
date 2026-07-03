# Releasing Glace

`Glace` uses Sparkle for in-app updates. A release is only usable by Sparkle when all of the following are published together:

- a signed `.dmg`
- a notarized `.dmg`
- an `appcast.xml`
- a Sparkle EdDSA signature generated from the private key matching `SUPublicEDKey`

The GitHub Actions workflow in `.github/workflows/release.yml` handles this when a GitHub release is published. Tag pushes alone do not publish binaries, which prevents duplicate release jobs.

## Required repository secrets

- `MACOS_CERTIFICATE_P12_BASE64`: base64-encoded Developer ID Application certificate (`.p12`)
- `MACOS_CERTIFICATE_PASSWORD`: password for the `.p12`
- `MACOS_KEYCHAIN_PASSWORD`: temporary keychain password used on the runner
- `APPLE_ID`: Apple account email used for notarization
- `APPLE_APP_SPECIFIC_PASSWORD`: app-specific password for notarization
- `APPLE_TEAM_ID`: Apple Developer team identifier
- `SPARKLE_PRIVATE_KEY`: Sparkle private EdDSA key matching `SUPublicEDKey` in `Ice/Resources/Info.plist`

## GitHub setup

- Enable GitHub Pages for this repository.
- Publish Pages from the `gh-pages` branch.
- Keep the repository secrets above available to the protected `release` environment.
- Create a GitHub release to trigger the workflow.
- Use a release tag in the exact form `vMAJOR.MINOR.PATCH`, for example `v2.0.0`.
- Bump `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the Xcode project before publishing. The workflow refuses to publish when the tag and project version differ, and it preserves the project build number so Sparkle always sees a newer build.

The workflow will:

1. archive and export the signed app
2. package it as `Glace-<version>.dmg`
3. notarize and staple the `.dmg`
4. generate release notes HTML and `appcast.xml`
5. push update metadata to `gh-pages`
6. upload the `.dmg` as a GitHub release asset
7. publish a GitHub artifact provenance attestation

## Glace 2.0 release checklist

1. Confirm `MARKETING_VERSION = 2.0.0` and `CURRENT_PROJECT_VERSION = 2000`.
2. Merge the release changes and wait for lint, CodeQL, and website publication.
3. Create `v2.0.0` from the verified `main` commit with the contents of `RELEASE_NOTES.md`.
4. Publish the GitHub release once. The release workflow signs, notarizes, staples, attests, and uploads `Glace-2.0.0.dmg`.
5. Verify the DMG with `gh attestation verify`, Gatekeeper, and the public Sparkle appcast.
