SUMMARY = "Early Audio Boot Optimizations"
LICENSE = "CLOSED"
inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(rb3gen2-core-kit)"

# pipewire is started by the udev rule when the sound card appears, not enabled
# into a systemd target, so nothing is auto-enabled here.
SYSTEMD_SERVICE:${PN} = ""

# Kodiak (sc7280 / qcm6490)
SRC_URI:rb3gen2-core-kit = " \
    file://audio-modules.conf \
    file://01-pipewire-audio.rules \
    file://pipewire.service \
    file://pipewire.socket.conf \
    file://pipewire-manager.socket.conf \
"

do_install:rb3gen2-core-kit() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/audio-modules.conf ${D}${sysconfdir}/modules-load.d/10-audio-modules.conf

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/01-pipewire-audio.rules ${D}${sysconfdir}/udev/rules.d/

    # pipewire is installed as a full unit; the sockets as drop-ins.
    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/pipewire.service ${D}${sysconfdir}/systemd/system/
    install -d ${D}${sysconfdir}/systemd/system/pipewire.socket.d/
    install -m 0644 ${UNPACKDIR}/pipewire.socket.conf \
        ${D}${sysconfdir}/systemd/system/pipewire.socket.d/zz-quickboot.conf
    install -d ${D}${sysconfdir}/systemd/system/pipewire-manager.socket.d/
    install -m 0644 ${UNPACKDIR}/pipewire-manager.socket.conf \
        ${D}${sysconfdir}/systemd/system/pipewire-manager.socket.d/zz-quickboot.conf
}

FILES:${PN} += "${sysconfdir}/modules-load.d/* ${sysconfdir}/udev/rules.d/* ${sysconfdir}/systemd/system/* ${sysconfdir}/systemd/system/*.socket.d/*"
