FROM mcr.microsoft.com/devcontainers/go:1-1.23-bookworm

# The base image ships a stale apt source for the Yarn repo whose baked-in
# keyring no longer validates (NO_PUBKEY), which breaks apt-get update. This
# project uses pnpm, not yarn, so drop that source entirely.
RUN rm -f /etc/apt/sources.list.d/yarn.list

# System libraries required to build/run Wails apps on Linux
# (GTK3 + WebKit2GTK for the native webview, appindicator for the systray,
# librsvg for icon rendering).
# gcc-mingw-w64-x86-64 + dbus provide a Windows cross-compile path (see
# scripts/build-windows.sh): Wails itself needs no cgo for windows/amd64, but
# the go-autostart dependency's Windows backend links ole32/uuid via cgo, and
# Wails' bindings-generation step runs the host binary locally (needs a D-Bus
# session for systray init).
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    gcc-mingw-w64-x86-64 \
    dbus \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the Wails CLI matching the version used by this project (see go.mod / CI workflow).
RUN go install github.com/wailsapp/wails/v2/cmd/wails@v2.11.0

# gopls@latest requires a newer Go toolchain than this image ships (base is
# go1.23), so pin the last gopls release that still supports go1.23.
RUN go install golang.org/x/tools/gopls@v0.18.1

# The base image's GOPATH (/go) is root:golang with group-writable dirs only
# at the top level; module cache subdirectories created during the RUN steps
# above are re-created read-only for the group by Go itself. Open them up so
# the non-root vscode user (member of the golang group) can install/update Go
# tools (e.g. gopls) later without hitting "permission denied".
RUN chmod -R g+w /go/pkg
