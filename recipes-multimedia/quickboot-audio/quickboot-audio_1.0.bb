SUMMARY = "Early Audio Boot Optimizations"
LICENSE = "CLOSED"
inherit systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
RDEPENDS:${PN} += "bash"

COMPATIBLE_MACHINE = "(iq-9075-evk|rb3gen2-core-kit)"

SYSTEMD_AUTO_ENABLE = "enable"

# IQ-9075 EVK (SA8775P / lemans)
SRC_URI:iq-9075-evk = " \
    file://audio-modules.conf \
    file://01-pipewire-audio.rules \
    file://pipewire.service \
    file://early_audio_play_app.service \
    file://audio_play_app.sh \
    file://sample-3s.wav \
"
SYSTEMD_SERVICE:${PN}:iq-9075-evk = "early_audio_play_app.service"

do_install:iq-9075-evk() {
    install -d ${D}${sysconfdir}/modules-load.d/
    install -m 0644 ${UNPACKDIR}/audio-modules.conf ${D}${sysconfdir}/modules-load.d/

    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 ${UNPACKDIR}/01-pipewire-audio.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/pipewire.service ${D}${sysconfdir}/systemd/system/
    install -m 0644 ${UNPACKDIR}/early_audio_play_app.service ${D}${sysconfdir}/systemd/system/

    install -d ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/audio_play_app.sh ${D}${bindir}/

    install -d ${D}/usr/share/sounds/
    install -m 0644 ${UNPACKDIR}/sample-3s.wav ${D}/usr/share/sounds/
}

FILES:${PN} += "${sysconfdir}/modules-load.d/* ${sysconfdir}/udev/rules.d/* ${sysconfdir}/systemd/system/* ${bindir}/* /usr/share/sounds/*"

# Kodiak (sc7280 / qcm6490)
SRC_URI:rb3gen2-core-kit = " \
    file://audio-modules.conf \
    file://01-pipewire-audio.rules \
    file://pipewire.service \
    file://pipewire.socket.conf \
    file://pipewire-manager.socket.conf \
    file://early_audio_play_app.service \
    file://audio_play_app.sh \
    file://sample-3s.wav \
"
SYSTEMD_SERVICE:${PN}:rb3gen2-core-kit = "early_audio_play_app.service"

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
    install -m 0644 ${UNPACKDIR}/early_audio_play_app.service ${D}${sysconfdir}/systemd/system/

    install -d ${D}${bindir}/
    install -m 0755 ${UNPACKDIR}/audio_play_app.sh ${D}${bindir}/

    install -d ${D}/data/
    install -m 0644 ${UNPACKDIR}/sample-3s.wav ${D}/data/
}

FILES:${PN}:rb3gen2-core-kit += "${sysconfdir}/systemd/system/*.socket.d/* /data/*"
