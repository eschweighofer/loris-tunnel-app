#!/usr/bin/env bash
# Cross-compile the Windows (windows/amd64) build from a Linux devcontainer.
#
# Requires (already provisioned in .devcontainer/Dockerfile):
#   - gcc-mingw-w64-x86-64 (cgo cross C compiler; go-autostart's Windows
#     backend links ole32/uuid via cgo)
#   - dbus (Wails' bindings-generation step runs the compiled host binary
#     locally to introspect it via reflection; main.go's systray init needs
#     a D-Bus session to avoid panicking in a headless container)
#
# Usage: scripts/build-windows.sh [extra wails build args...]
#
# Note: this is a convenience cross-build for local iteration. The
# authoritative Windows build/signing/packaging path is the windows-latest
# GitHub Actions runner in .github/workflows/build.yml.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v x86_64-w64-mingw32-gcc >/dev/null 2>&1; then
  echo "error: x86_64-w64-mingw32-gcc not found. Install gcc-mingw-w64-x86-64." >&2
  exit 1
fi

if ! command -v dbus-run-session >/dev/null 2>&1; then
  echo "error: dbus-run-session not found. Install dbus." >&2
  exit 1
fi

exec dbus-run-session -- env \
  CGO_ENABLED=1 \
  CC=x86_64-w64-mingw32-gcc \
  GOOS=windows \
  GOARCH=amd64 \
  wails build -platform windows/amd64 -clean "$@"
