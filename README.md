# vendor/oplus/camera — RMX1931 Stock OPlus/Oppo Camera Port

Stock **realmeUI F.14** (`com.oppo.camera`) forward-port for **Realme X2 Pro (samurai / RMX1931)** on AOSP / Infinity-X (sm8150+).

## What this ships

| Component | Path | Priority |
|-----------|------|----------|
| OppoCamera.apk | `priv-app/OppoCamera/` | P0 app |
| Camera Unit SDK | `framework/com.oppo.camera.unit.sdk.jar` | P1 |
| APS JPEG/EXIF | `lib64/odm/libapsjpeg.so`, `libapsexif.so` | P0 (NEEDED by libAlgoProcess) |
| FaceBeauty | `libFaceBeautyCap.so`, `libFaceBeautyPre.so` | P1 |
| Polarr / blur / watermark | `libPolarrRender`, `libstblur_api`, … | P1–P2 |
| Models / LUTs | `etc/camera/{darksight,fb_model,filters_*,megvii,tonemap,singleblur}` | P1–P2 |
| Privapp + hidden API | `etc/permissions`, `etc/sysconfig` | P0 policy |

Base CamX / sensor / ArcSoft / SNPE HAL blobs stay in **`vendor/realme/samurai`** (device proprietary tree).

## Full Android tree layout

```text
vendor/oplus/camera/          ← this repo
device/realme/samurai/        ← device tree (inherits camera.mk)
vendor/realme/samurai/        ← proprietary HAL/CamX
```

## Enable / disable

`device/realme/samurai/device.mk` already has:

```make
$(call inherit-product-if-exists, vendor/oplus/camera/camera.mk)
```

Disable stock app only (keep HAL):

```make
TARGET_USES_OPLUS_CAMERA := false
```

## Re-extract from F.14 dump

```bash
./scripts/extract-from-f14-dump.sh /path/to/RUI_F-14_Global_full_dump
```

## Bring-up order

1. Confirm QTI camera provider + Snap/Aperture open all 4 rear + front sensors.
2. Flash with `TARGET_USES_OPLUS_CAMERA=true`.
3. `adb shell pm path com.oppo.camera` → product priv-app.
4. Launch Camera → preview → capture → video.
5. Then Portrait / Night / HDR / Filters.

## Known gaps (Android 16)

- Stock APK targets API 29 / compile 30; hidden-api whitelist is required.
- OEM permissions (`oppo.permission.*`, `heytap.*`) are **not** defined on AOSP — related features may no-op.
- Full `oplus-framework.jar` is **not** injected (bootclasspath risk). App may miss some ColorOS-only APIs.
- SELinux: start with collected denials (`adb shell dmesg | grep avc`) and tighten `sepolicy/`.
- Some proprietary-files entries (`libapsdarksight`, `libOPLUS_SCPortrait`) are **not** in F.14 global dump (other OP4A89 sources).

## Package identity

```text
package: com.oppo.camera
versionName: 3.102.357
versionCode: 40027
```

Device props must use **`com.oppo.camera`**, not `com.oplus.camera`.

## Debug

```bash
adb logcat -s CamX:V CHIUSECASE:V APS:V OppoCamera:V AndroidRuntime:E
adb shell lshal | grep camera
adb shell dumpsys media.camera
```
