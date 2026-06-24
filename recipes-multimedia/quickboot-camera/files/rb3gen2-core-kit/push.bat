@echo off
REM ===========================================================================
REM Quick-verify deploy script for rb3gen2-core-kit (Kodiak, sc7280) - CAMERA.
REM
REM Pushes the quickboot-camera files to the same locations the Yocto recipe
REM (quickboot-camera_1.0.bb -> do_install:rb3gen2-core-kit) installs them to,
REM so you can iterate on a running board without a full image rebuild.
REM
REM NOTE: this target enables cam-server.service (not the preview app), and
REM the CamX override settings live at the rootfs top level (/).
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
adb shell rm -f /etc/modules-load.d/camera-modules.conf /etc/modules-load.d/camera_modules.conf
adb push "%DIR%camera-modules.conf" /etc/modules-load.d/20-camera-modules.conf

echo [*] Pushing udev rule...
adb push "%DIR%02-cam-server.rules" /etc/udev/rules.d/02-cam-server.rules

echo [*] Pushing systemd units...
adb push "%DIR%cam-server.service" /etc/systemd/system/cam-server.service
adb push "%DIR%early_cam_preview_app.service" /etc/systemd/system/early_cam_preview_app.service

echo [*] Pushing CamX override settings to rootfs top level...
adb push "%DIR%camxoverridesettings.txt" /camxoverridesettings.txt

echo [*] Pushing preview app...
adb push "%DIR%cam_preview_app.sh" /usr/bin/cam_preview_app.sh
adb shell chmod 0755 /usr/bin/cam_preview_app.sh

echo [*] Reloading systemd + udev and disabling target-based startup...
adb shell systemctl daemon-reload
adb shell udevadm control --reload-rules
adb shell systemctl disable cam-server.service
adb shell systemctl enable early_cam_preview_app.service

echo.
echo [+] Done. Reboot to verify, or trigger now with:
echo       adb shell systemctl start cam-server.service
echo     Check timing with:
echo       adb shell journalctl -b -u cam-server.service
echo       adb shell dmesg ^| grep -i cam

endlocal
