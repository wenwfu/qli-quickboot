# meta-qli-quickboot

A Yocto layer that reduces multimedia-subsystem boot time on Qualcomm Linux
Embedded platforms. It packages early-boot optimizations for audio, camera, and
display as the recipes `quickboot-audio`, `quickboot-camera`, and
`quickboot-display`.

These recipes strip desktop overhead, drive services from event-based hardware
triggers (udev rules), enforce kernel-module load ordering, and detach critical
services from the standard systemd boot targets to bring multimedia up early.

## Supported machines

| `MACHINE` | Platform | SoC |
|-----------|----------|-----|
| `iq-9075-evk` | IQ-9075 EVK | SA8775P (lemans) |
| `rb3gen2-core-kit` | Kodiak | sc7280 (qcm6490) |

Per-machine files live under `<recipe>/files/<MACHINE>/` and are selected via
BitBake's `FILESOVERRIDES`; recipe logic is split into `:<MACHINE>` override
blocks. `COMPATIBLE_MACHINE` restricts each build to its supported targets.

## Layout

```
meta-qli-quickboot/
├── conf/
│   └── layer.conf
└── recipes-multimedia/
    ├── quickboot-audio/
    ├── quickboot-camera/
    └── quickboot-display/
```

## Dependencies

This layer depends on `core` (OpenEmbedded-Core / `meta`). It is compatible with
the `scarthgap`, `styhead`, and `walnascar` Yocto series.

## Usage

Add the layer to your build:

```
bitbake-layers add-layer /path/to/meta-qli-quickboot
```

Then install the packages into your image (e.g. in the image recipe or
`local.conf`):

```
IMAGE_INSTALL:append = " quickboot-audio quickboot-camera quickboot-display"
```

The correct per-machine variant is selected automatically from the active
`MACHINE`. Each recipe's `COMPATIBLE_MACHINE` limits it to the targets it
supports, so on other machines it is skipped rather than failing the build.
