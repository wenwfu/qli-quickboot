@echo off
REM ===========================================================================
REM Quick-verify deploy script for iq-9075-evk (SA8775P / lemans).
REM
REM Pushes the quickboot-audio files to the same locations the Yocto recipe
REM (quickboot-audio_1.0.bb -> do_install:iq-9075-evk) installs them to, so
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
adb push "%DIR%audio-modules.conf" /etc/modules-load.d/audio-modules.conf

echo [*] Pushing udev rule...
adb push "%DIR%01-pipewire-audio.rules" /etc/udev/rules.d/01-pipewire-audio.rules

echo [*] Pushing systemd units...
adb push "%DIR%pipewire.service" /etc/systemd/system/pipewire.service
adb push "%DIR%early_audio_play_app.service" /etc/systemd/system/early_audio_play_app.service

echo [*] Pushing playback app...
adb push "%DIR%audio_play_app.sh" /usr/bin/audio_play_app.sh
adb shell chmod 0755 /usr/bin/audio_play_app.sh

echo [*] Pushing sample chime...
adb shell mkdir -p /usr/share/sounds
adb push "%DIR%sample-3s.wav" /usr/share/sounds/sample-3s.wav

echo [*] Reloading systemd + udev and enabling service...
adb shell systemctl daemon-reload
adb shell udevadm control --reload-rules
adb shell systemctl enable early_audio_play_app.service

echo.
echo [+] Done. Reboot to verify early chime, or trigger now with:
echo       adb shell systemctl start early_audio_play_app.service
echo     Check timing with:
echo       adb shell journalctl -b -u early_audio_play_app.service
echo       adb shell dmesg ^| grep quickboot

endlocal
