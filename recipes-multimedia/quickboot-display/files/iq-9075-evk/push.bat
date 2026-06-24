@echo off
REM ===========================================================================
REM Quick-verify deploy script for iq-9075-evk (SA8775P / lemans) - DISPLAY.
REM
REM Pushes the quickboot-display files to the same locations the Yocto recipe
REM (quickboot-display_1.0.bb -> do_install:iq-9075-evk) installs them to, so
REM you can iterate on a running board without a full image rebuild.
REM
REM NOTE: weston starts via socket activation on this target, so the .socket
REM unit is enabled (not the .service).
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
adb push "%DIR%display-modules.conf" /etc/modules-load.d/display-modules.conf

echo [*] Pushing modprobe config...
adb push "%DIR%drm-modprobe.conf" /etc/modprobe.d/drm-modprobe.conf

echo [*] Pushing udev rule...
adb push "%DIR%03-drm.rules" /etc/udev/rules.d/03-drm.rules

echo [*] Pushing systemd units...
adb push "%DIR%weston.service" /etc/systemd/system/weston.service
adb push "%DIR%weston.socket" /etc/systemd/system/weston.socket

echo [*] Reloading systemd + udev and enabling weston socket...
adb shell systemctl daemon-reload
adb shell udevadm control --reload-rules
adb shell systemctl enable weston.socket

echo.
echo [+] Done. Reboot to verify early display, or trigger now with:
echo       adb shell systemctl start weston.socket
echo     Check timing with:
echo       adb shell journalctl -b -u weston.service
echo       adb shell dmesg ^| grep -i drm

endlocal
