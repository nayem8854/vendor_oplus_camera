# Bring-up & debug guide — RMX1931 OPlus Camera

## Stage 0 — Base HAL (no stock app)

Prereq: Infinity-X / AOSP build boots; Aperture or Snap can open cameras.

```bash
adb shell ps -A | grep -E 'provider@2.4|cameraserver'
adb shell lshal | grep camera
adb shell dumpsys media.camera | head -80
```

Expected sensors (F.14 / samurai):

| Logical | Sensor | Role |
|---------|--------|------|
| 0 | s5kgw1 | 64MP main |
| 1 | imx471 | front |
| 2 | s5k3m5sx | tele |
| 3 | imx319 | ultrawide |
| 4 | ov02a1b | depth |

## Stage 1 — Stock app install

```bash
adb shell pm path com.oppo.camera
# package:/product/priv-app/OppoCamera/OppoCamera.apk
adb shell dumpsys package com.oppo.camera | grep -E 'pkgFlags|granted=true' | head
```

If missing priv permissions:

```bash
adb shell cat /system_ext/etc/permissions/privapp-permissions-com.oppo.camera.xml
```

## Stage 2 — Native APS chain

`libAlgoProcess.so` **NEEDED**:

- `libapsjpeg.so`
- `libapsexif.so`
- `libmpbase.so`
- `libbsproxy.so`
- `vendor.qti.hardware.camera.postproc@1.0.so`

`libAlgoInterface.so` also needs `libPolarrRender.so`, `libXDocProcessSDK.so`.

```bash
adb shell ls -l /odm/lib64/libapsjpeg.so /odm/lib64/libapsexif.so /odm/lib64/libbsproxy.so /odm/lib64/libPolarrRender.so
adb shell ls /odm/etc/camera/config/
adb shell ls /odm/etc/camera/darksight/ /odm/etc/camera/megvii/
```

## Stage 3 — Failure matrix

| Symptom | Check |
|---------|--------|
| App not installed | `PRODUCT_PACKAGES`, `TARGET_USES_OPLUS_CAMERA` |
| Instant crash on open | hidden-api whitelist; logcat `UnsupportedOperationException` |
| `UnsatisfiedLinkError` | missing `/odm/lib64` or APK jni libs |
| Black preview | HAL/CamX; `vendor.camera.aux.packagelist` |
| Green/pink preview | sensor tune / format; not app |
| Capture OK, beauty fail | `libFaceBeauty*`, `fb_model/` |
| Night fail | ArcSoft super night + `darksight/*.bin` + HVX skel on ADSP |
| Portrait fail | dualcam refocus libs + stereo params |
| SELinux deny | `adb shell su 0 dmesg \| grep avc` |

## Stage 4 — Manual test checklist

- [ ] Photo main / UW / tele / front  
- [ ] 4K / 60fps video  
- [ ] Portrait  
- [ ] Night  
- [ ] HDR  
- [ ] Beauty slider  
- [ ] Filters  
- [ ] Watermark  
- [ ] Slow-mo / timelapse  
- [ ] Flash / torch (no motor flashlight prop)  
- [ ] Google Lens entry (if GApps)  

## Props reference (stock F.14)

```text
ro.oplus.system.camera.name=com.oppo.camera
ro.com.google.lens.oem_camera_package=com.oppo.camera
vendor.camera.aux.packagelist=android,com.oppo.engineermode.camera,com.oppo.camera,...
persist.vendor.camera.privapp.list=com.oppo.camera,...
```
