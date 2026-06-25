SUMMARY = "Early Camera Boot Optimizations"
LICENSE = "CLOSED"
inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

COMPATIBLE_MACHINE = "(rb3gen2-core-kit)"

# cam-server is device-triggered by 02-cam-server.rules, so it is not enabled
# into multi-user.target.
SYSTEMD_SERVICE:${PN} = ""

# Kodiak (sc7280 / qcm6490)
SRC_URI:rb3gen2-core-kit = " \
    file://camera-modules.conf \
    file://02-cam-server.rules \
    file://cam-server.service \
"

do_install:rb3gen2-core-kit() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/camera-modules.conf ${D}${sysconfdir}/modules-load.d/20-camera-modules.conf

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/02-cam-server.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/cam-server.service ${D}${sysconfdir}/systemd/system/
}

FILES:${PN} += "${sysconfdir}/modules-load.d/* ${sysconfdir}/udev/rules.d/* ${sysconfdir}/systemd/system/*"
