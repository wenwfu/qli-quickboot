@echo off
REM ===========================================================================
REM Quick-verify deploy script for rb3gen2-core-kit (Kodiak, sc7280) - DISPLAY.
REM
REM Pushes the quickboot-display files to the same locations the Yocto recipe
REM (quickboot-display_1.0.bb -> do_install:rb3gen2-core-kit) installs them to,
REM so you can iterate on a running board without a full image rebuild.
REM
REM NOTE: on this target weston is triggered via its .service (off DRM card0),
REM and there are extra modprobe drop-ins (msm softdep + CoreSight blacklist).
REM
REM Run from a Windows host with adb on PATH and the device connected.
REM ===========================================================================

setlocal
set DIR=%~dp0

echo [*] Preparing device (root + remount rw)...
adb root
adb wait-for-device
adb remount

echo [*] Pushing kernel module load order...
adb shell rm -f /etc/modules-load.d/display-modules.conf /etc/modules-load.d/01-display.conf
adb push "%DIR%display-modules.conf" /etc/modules-load.d/00-display-modules.conf

echo [*] Pushing modprobe configs...
adb push "%DIR%00-msm-softdep.conf" /etc/modprobe.d/00-msm-softdep.conf
adb push "%DIR%blacklist-bootspeed.conf" /etc/modprobe.d/blacklist-bootspeed.conf

echo [*] Pushing udev rule...
adb push "%DIR%03-drm.rules" /etc/udev/rules.d/03-drm.rules

echo [*] Pushing systemd units...
adb push "%DIR%weston.service" /etc/systemd/system/weston.service
REM weston.socket stays as a drop-in (only DefaultDependencies=no).
adb shell mkdir -p /etc/systemd/system/weston.socket.d
adb push "%DIR%weston.socket.conf" /etc/systemd/system/weston.socket.d/zz-quickboot.conf

echo [*] Reloading systemd + udev...
adb shell systemctl daemon-reload
adb shell udevadm control --reload-rules

echo.
echo [+] Done. Reboot to verify early display, or trigger now with:
echo       adb shell systemctl start weston.service
echo     Check timing with:
echo       adb shell journalctl -b -u weston.service
echo       adb shell dmesg ^| grep -i drm

endlocal
