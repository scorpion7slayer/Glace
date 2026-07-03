#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="Glace"
BUNDLE_ID="com.theo.Glace"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="$ROOT_DIR/.build/DerivedData"
APP_BUNDLE="$DERIVED_DATA/Build/Products/Debug/$APP_NAME.app"
APP_BINARY="$APP_BUNDLE/Contents/MacOS/$APP_NAME"

if [[ -z "${DEVELOPER_DIR:-}" ]]; then
  if [[ -d /Applications/Xcode-beta.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
  elif [[ -d /Applications/Xcode.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
  fi
fi

if ! xcodebuild -version >/dev/null 2>&1; then
  echo "Xcode is required. Install Xcode or set DEVELOPER_DIR to its Developer directory." >&2
  exit 1
fi

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

SIGNING_IDENTITY="${GLACE_CODE_SIGN_IDENTITY:-}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
  SIGNING_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | awk '/"Apple Development:/{print $2; exit}')"
fi

if [[ -n "$SIGNING_IDENTITY" ]]; then
  echo "Signing with a stable Apple Development identity so macOS permissions persist between builds."
  SIGNING_ARGUMENTS=(
    "CODE_SIGN_IDENTITY=$SIGNING_IDENTITY"
    CODE_SIGN_STYLE=Manual
    DEVELOPMENT_TEAM=
    CODE_SIGNING_ALLOWED=YES
  )
else
  echo "Warning: no Apple Development identity found; permissions may need to be granted after each build." >&2
  SIGNING_ARGUMENTS=(
    CODE_SIGN_IDENTITY=-
    CODE_SIGN_STYLE=Manual
    DEVELOPMENT_TEAM=
    CODE_SIGNING_ALLOWED=YES
  )
fi

xcodebuild \
  -project "$ROOT_DIR/Ice.xcodeproj" \
  -scheme Ice \
  -configuration Debug \
  -destination "platform=macOS,arch=$(uname -m)" \
  -derivedDataPath "$DERIVED_DATA" \
  ONLY_ACTIVE_ARCH=YES \
  "${SIGNING_ARGUMENTS[@]}" \
  build

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 2
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
