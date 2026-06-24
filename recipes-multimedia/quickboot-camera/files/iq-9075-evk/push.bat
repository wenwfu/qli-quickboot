@echo off
REM ===========================================================================
REM Quick-verify deploy script for iq-9075-evk (SA8775P / lemans) - CAMERA.
REM
REM Pushes the quickboot-camera files to the same locations the Yocto recipe
REM (quickboot-camera_1.0.bb -> do_install:iq-9075-evk) installs them to, so
REM you can iterate on a running board without a full image rebuild.
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
adb push "%DIR%camera-modules.conf" /etc/modules-load.d/camera-modules.conf

echo [*] Pushing udev rule...
adb push "%DIR%02-cam-server.rules" /etc/udev/rules.d/02-cam-server.rules

echo [*] Pushing systemd units...
adb push "%DIR%cam-server.service" /etc/systemd/system/cam-server.service
adb push "%DIR%early_cam_preview_app.service" /etc/systemd/system/early_cam_preview_app.service

echo [*] Pushing apps...
adb push "%DIR%cam_preview_app.sh" /usr/bin/cam_preview_app.sh
adb push "%DIR%iq9075-first-boot-cam-setup.sh" /usr/bin/iq9075-first-boot-cam-setup.sh
adb shell chmod 0755 /usr/bin/cam_preview_app.sh /usr/bin/iq9075-first-boot-cam-setup.sh

echo [*] Reloading systemd + udev and enabling service...
adb shell systemctl daemon-reload
adb shell udevadm control --reload-rules
adb shell systemctl enable early_cam_preview_app.service

echo.
echo [+] Done. Reboot to verify early preview, or trigger now with:
echo       adb shell systemctl start early_cam_preview_app.service
echo     Check timing with:
echo       adb shell journalctl -b -u early_cam_preview_app.service
echo       adb shell dmesg ^| grep -i cam

endlocal
