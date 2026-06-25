SUMMARY = "Early Display Boot Optimizations"
LICENSE = "CLOSED"
inherit systemd

S = "${UNPACKDIR}"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(rb3gen2-core-kit)"

# Kodiak (sc7280 / qcm6490)
SRC_URI:rb3gen2-core-kit = " \
    file://display-modules.conf \
    file://00-msm-softdep.conf \
    file://03-drm.rules \
    file://weston.service \
    file://weston.socket.conf \
"

do_install:rb3gen2-core-kit() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/display-modules.conf ${D}${sysconfdir}/modules-load.d/00-display-modules.conf

    install -d ${D}${sysconfdir}/modprobe.d/
    install -m 0644 ${UNPACKDIR}/00-msm-softdep.conf ${D}${sysconfdir}/modprobe.d/

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/03-drm.rules ${D}${sysconfdir}/udev/rules.d/

    # weston is installed as a full unit; the socket as a drop-in.
    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/weston.service ${D}${sysconfdir}/systemd/system/
    install -d ${D}${sysconfdir}/systemd/system/weston.socket.d/
    install -m 0644 ${UNPACKDIR}/weston.socket.conf \
        ${D}${sysconfdir}/systemd/system/weston.socket.d/zz-quickboot.conf
}

FILES:${PN} += "${sysconfdir}/modules-load.d/* ${sysconfdir}/modprobe.d/* ${sysconfdir}/udev/rules.d/* ${sysconfdir}/systemd/system/* ${sysconfdir}/systemd/system/*.socket.d/*"
