#!/bin/sh
#
# /usr/bin/cam_preview_app.sh
# Start a gst-launch camera preview pipeline. Robust against weston not yet
# having created the wayland socket when this service starts (race with
# weston's Type=notify ready signal).

echo "[INFO] =========================================="
echo "[INFO] GST CMD Started"
echo "[INFO] =========================================="

export XDG_RUNTIME_DIR=/run/weston
export WAYLAND_DISPLAY=wayland-1

# GStreamer plugin-registry cache. Without this the first gst-launch rebuilds
# the whole registry (scanning every plugin, even initialising the Adreno
# Vulkan driver) which cost ~1.3s in the boot trace - far more than weston or
# cam-server startup. Pin the cache to a fixed, writable, persistent path and
# allow it to be (re)built: GST_REGISTRY_UPDATE=no with no existing cache was
# the worst case - it scanned every boot yet never saved the result. With the
# cache present, subsequent boots skip the scan entirely.
export GST_REGISTRY=/var/cache/gstreamer-1.0/registry.aarch64.bin
export GST_REGISTRY_UPDATE=yes
export GST_DEBUG=1

echo "[INFO] XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}"
echo "[INFO] WAYLAND_DISPLAY=${WAYLAND_DISPLAY}"
echo "[INFO] GST_REGISTRY=${GST_REGISTRY}"
echo "[INFO] GST_REGISTRY_UPDATE=${GST_REGISTRY_UPDATE}"

# Make sure the registry cache directory exists and is writable, otherwise the
# cache can never be saved and every boot pays the full scan.
mkdir -p "$(dirname "$GST_REGISTRY")" 2>/dev/null || true

# Poll up to 5s for the wayland socket. Try $XDG_RUNTIME_DIR first, then a
# few common fallbacks so this script works whether weston runs as root
# (/run/weston) or under a normal user (/run/user/<uid>).
WAYLAND_SOCKET=""
for i in $(seq 1 250); do
    for d in "${XDG_RUNTIME_DIR:-}" /run/weston /run/user/0 /run/user/1000; do
        [ -z "$d" ] && continue
        s="$d/${WAYLAND_DISPLAY:-wayland-1}"
        if [ -S "$s" ]; then
            WAYLAND_SOCKET="$s"
            export XDG_RUNTIME_DIR="$d"
            break 2
        fi
    done
    sleep 0.02
done

if [ -z "$WAYLAND_SOCKET" ]; then
    echo "[ERROR] Wayland socket not found after 5s wait" >&2
    echo "[INFO] Existing Wayland sockets on system:" >&2
    find /run /tmp /var/run -maxdepth 3 -type s -name 'wayland-*' -print 2>/dev/null >&2
    exit 1
fi

echo "[INFO] Using Wayland socket: $WAYLAND_SOCKET (XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR)"

echo "[INFO] Command:"
echo "[INFO] /usr/bin/gst-launch-1.0 -e qtiqmmfsrc name=camsrc video_0::type=preview ! video/x-raw,format=NV12_Q08C,width=1280,height=720,framerate=30/1 ! waylandsink fullscreen=false"

exec /usr/bin/gst-launch-1.0 -e \
    qtiqmmfsrc name=camsrc video_0::type=preview \
    ! video/x-raw,format=NV12_Q08C,width=1280,height=720,framerate=30/1 \
    ! waylandsink fullscreen=false
