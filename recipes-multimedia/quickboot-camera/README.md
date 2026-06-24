# Quickboot Camera Optimizations

This package optimizes camera boot time (Time-to-First-Frame) via a systemd
service, udev rule, kernel module load list, and CamX overrides. A single
recipe covers multiple machines; per-machine files live under
`files/<MACHINE>/`.

## Kodiak (`rb3gen2-core-kit`, sc7280 / qcm6490)

`cam-server` is the primary boot service. The preview app is installed but not
auto-enabled.

| File | Destination | Purpose |
|------|-------------|---------|
| `cam-server.service`      | `/etc/systemd/system/` | Full replacement for the vendor `cam-server.service`: detached from the default boot target, started as soon as `/dev/video0` appears. Shipped as a full unit (not a drop-in) because a drop-in cannot clear the vendor unit's list deps (e.g. `After=var-volatile-lib.service`). |
| `02-cam-server.rules`     | `/etc/udev/rules.d/`   | Tags the `video0` device for systemd and triggers `cam-server.service`. |
| `camera-modules.conf`     | `/etc/modules-load.d/` | Forces the sc7280 camera/V4L2 kernel modules to load early in dependency order. |
| `camxoverridesettings.txt`| `/`                    | Disables the unused NCS sensor service (`enableNCSService=FALSE`), avoiding a ~55s QMI wait at boot. |
| `cam_preview_app.sh`      | `/usr/bin/`            | gst-launch preview pipeline; waits for the Wayland socket, then renders the camera preview via `waylandsink`. |
| `early_cam_preview_app.service` | `/etc/systemd/system/` | Runs the preview app after `weston.service` and `cam-server.service`. Installed but **not** auto-enabled — enable manually with `systemctl enable early_cam_preview_app`. |

## IQ-9075 EVK (`iq-9075-evk`, SA8775P)

The preview app is the primary boot service. A mandatory first-boot script
initializes EFI variables and trims unused sensor binaries.

| File | Destination | Purpose |
|------|-------------|---------|
| `early_cam_preview_app.service` | `/etc/systemd/system/` | Primary boot service; runs the camera preview app. |
| `cam-server.service`      | `/etc/systemd/system/` | Camera server, started on-demand by udev. |
| `02-cam-server.rules`     | `/etc/udev/rules.d/`   | Triggers `cam-server.service` on video device detection. |
| `camera-modules.conf`     | `/etc/modules-load.d/` | Forces the SA8775P camera/V4L2 kernel modules to load early. |
| `cam_preview_app.sh`      | `/usr/bin/`            | gst-launch preview pipeline. |
| `iq9075-first-boot-cam-setup.sh` | `/usr/bin/`     | Run once after first boot: initializes EFI vars and removes unused sensor binaries. |
