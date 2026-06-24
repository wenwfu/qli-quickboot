SUMMARY = "Early Camera Boot Optimizations"
LICENSE = "CLOSED"
inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
RDEPENDS:${PN} += "bash"

COMPATIBLE_MACHINE = "(iq-9075-evk|rb3gen2-core-kit)"

SYSTEMD_AUTO_ENABLE = "enable"

# IQ-9075 EVK (SA8775P / lemans)
SRC_URI:iq-9075-evk = " \
    file://camera-modules.conf \
    file://02-cam-server.rules \
    file://cam-server.service \
    file://early_cam_preview_app.service \
    file://cam_preview_app.sh \
    file://iq9075-first-boot-cam-setup.sh \
"
SYSTEMD_SERVICE:${PN}:iq-9075-evk = "early_cam_preview_app.service"

do_install:iq-9075-evk() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/camera-modules.conf ${D}${sysconfdir}/modules-load.d/

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/02-cam-server.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/cam-server.service ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/early_cam_preview_app.service ${D}${sysconfdir}/systemd/system/

    install -d ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/cam_preview_app.sh ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/iq9075-first-boot-cam-setup.sh ${D}${bindir}/
}

# Kodiak (sc7280 / qcm6490)
SRC_URI:rb3gen2-core-kit = " \
    file://camera-modules.conf \
    file://02-cam-server.rules \
    file://cam-server.service \
    file://camxoverridesettings.txt \
    file://early_cam_preview_app.service \
    file://cam_preview_app.sh \
"
# cam-server is device-triggered by 02-cam-server.rules, so it is not enabled
# into multi-user.target.
SYSTEMD_SERVICE:${PN}:rb3gen2-core-kit = ""

do_install:rb3gen2-core-kit() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/camera-modules.conf ${D}${sysconfdir}/modules-load.d/20-camera-modules.conf

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/02-cam-server.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/cam-server.service ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/early_cam_preview_app.service ${D}${sysconfdir}/systemd/system/

    install -m 0644 ${UNPACKDIR}/camxoverridesettings.txt ${D}/camxoverridesettings.txt

    install -d ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/cam_preview_app.sh ${D}${bindir}/
}

FILES:${PN} += "${sysconfdir}/modules-load.d/* ${sysconfdir}/udev/rules.d/* ${sysconfdir}/systemd/system/* ${bindir}/*"
FILES:${PN}:append:rb3gen2-core-kit = " /camxoverridesettings.txt"
