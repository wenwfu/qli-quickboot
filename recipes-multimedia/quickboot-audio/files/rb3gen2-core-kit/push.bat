@echo off
REM ===========================================================================
REM Quick-verify deploy script for rb3gen2-core-kit (Kodiak, sc7280 / qcm6490).
REM
REM Pushes the quickboot-audio files to the same locations the Yocto recipe
REM (quickboot-audio_1.0.bb -> do_install:rb3gen2-core-kit) installs them to,
REM so you can iterate on a running board without a full image rebuild.
REM
REM NOTE: unlike iq-9075-evk, the early-play service reads the chime from
REM /data (matching early_audio_play_app.service on this target), so the WAV
REM is pushed to /data here, not /usr/share/sounds.
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
adb shell rm -f /etc/modules-load.d/audio-modules.conf
adb push "%DIR%audio-modules.conf" /etc/modules-load.d/10-audio-modules.conf

echo [*] Pushing udev rule...
adb push "%DIR%01-pipewire-audio.rules" /etc/udev/rules.d/01-pipewire-audio.rules

echo [*] Pushing systemd units...
adb push "%DIR%pipewire.service" /etc/systemd/system/pipewire.service
REM sockets stay as drop-ins (only DefaultDependencies=no).
adb shell mkdir -p /etc/systemd/system/pipewire.socket.d
adb push "%DIR%pipewire.socket.conf" /etc/systemd/system/pipewire.socket.d/zz-quickboot.conf
adb shell mkdir -p /etc/systemd/system/pipewire-manager.socket.d
adb push "%DIR%pipewire-manager.socket.conf" /etc/systemd/system/pipewire-manager.socket.d/zz-quickboot.conf
adb push "%DIR%early_audio_play_app.service" /etc/systemd/system/early_audio_play_app.service

echo [*] Pushing playback app...
adb push "%DIR%audio_play_app.sh" /usr/bin/audio_play_app.sh
adb shell chmod 0755 /usr/bin/audio_play_app.sh

echo [*] Pushing sample chime to /data...
adb shell mkdir -p /data
adb push "%DIR%sample-3s.wav" /data/sample-3s.wav

echo [*] Reloading systemd + udev...
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
