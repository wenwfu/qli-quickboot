# Qualcomm QuickBoot Optimizations

## Overview

This repository contains a modular set of Yocto packages (`quickboot-audio`,
`quickboot-camera`, and `quickboot-display`) designed to significantly reduce
the boot time of multimedia subsystems on Qualcomm Linux Embedded platforms.

By default, Linux distribution frameworks (like systemd, logind, and udev)
prioritize desktop-like flexibility over raw boot speed. These packages
aggressively strip out desktop overhead, leverage event-driven hardware
triggers (udev rules), enforce kernel-module load ordering, and detach critical
services from the standard systemd boot targets to achieve sub-second
multimedia availability.

## Supported target

The recipes currently target a single machine. `COMPATIBLE_MACHINE` restricts
the build to it, so the packages are skipped (rather than failing) on other
machines.

| `MACHINE` | Platform | SoC | Notes |
|-----------|----------|-----|-------|
| `rb3gen2-core-kit` | Kodiak | sc7280 (qcm6490) | `cam-server` is the primary boot service, device-triggered off `video0`; `msm` softdep ordering; `weston` service-triggered off DRM `card0`; `pipewire` started off the sound card. `pipewire` and `weston` ship as full units replacing the vendor ones (a drop-in cannot clear the vendor units' `After=`/`Requires=` deps); their `.socket` units ship as drop-ins (only `DefaultDependencies=no`). |

The recipe logic lives in `:rb3gen2-core-kit` override blocks, and the
per-machine files under `<package>/files/rb3gen2-core-kit/` are selected
automatically by BitBake's `FILESOVERRIDES`.

To add another target: create `<package>/files/<NEW_MACHINE>/` with that
platform's files, add a `SRC_URI:<NEW_MACHINE>` + `do_install:<NEW_MACHINE>`
block to each recipe, and extend `COMPATIBLE_MACHINE`.

## Layout

```
quickboot-<subsystem>/
├── quickboot-<subsystem>_1.0.bb   # one recipe, per-machine override blocks
└── files/
    └── rb3gen2-core-kit/          # sc7280 / qcm6490 files
```

## Requirements

- A Yocto / OpenEmbedded build environment for the target Qualcomm Linux image.
- The recipes inherit `systemd` and expect a systemd-based rootfs.

## Installation

Add the package(s) to your image, e.g. in your image recipe or local.conf:

```
IMAGE_INSTALL:append = " quickboot-audio quickboot-camera quickboot-display"
```

The correct per-machine variant is selected automatically from the active
`MACHINE` at build time. Each recipe's `COMPATIBLE_MACHINE` limits it to the
targets it supports, so on other machines it is skipped rather than failing the
build.

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branching strategy and pull
request process.

## Getting in Contact

* [Report an Issue on GitHub](../../issues)
* [Open a Discussion on GitHub](../../discussions)

## License

This project is licensed under the [BSD-3-Clause License](https://spdx.org/licenses/BSD-3-Clause.html).
See [LICENSE.txt](LICENSE.txt) for the full license text.
