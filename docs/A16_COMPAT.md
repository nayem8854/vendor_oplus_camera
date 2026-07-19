# Android 16.2 compatibility — APK / JAR reality

## Short answer

**No tool can fully convert ColorOS 11 (`targetSdk 29`) OppoCamera + OEM JARs into a true Android 16.2 first-party camera.**

What we *can* do (and did):

| Artifact | Action | Result |
|----------|--------|--------|
| `OppoCamera.apk` | apktool manifest modernize + rebuild | **Partial** A13/A16 install/runtime survival |
| `com.oppo.camera.unit.sdk.jar` | shipped as-is | Still A11 DEX; optional shared lib |
| `oplus-framework-a11.jar` | staged only | **Not** on bootclasspath (bootloop risk) |

## OppoCamera.apk changes (`3.102.357-a16compat` / versionCode `40028`)

- `minSdk 28`, **`targetSdk 33`** (not 36 — higher targetSdk without source fixes *breaks more*)
- `compileSdk 34` metadata
- Android 13+ permissions: `READ_MEDIA_*`, `POST_NOTIFICATIONS`, FGS camera/mic
- `<queries>` for package visibility
- `requestLegacyExternalStorage` / `preserveLegacyExternalStorage`
- `android:exported` on components with intent-filters
- Build signs with **platform** cert via `Android.bp` (`certificate: "platform"`)

Bytecode / native `.so` inside the APK are **still Android 11-era**.

## What is still NOT “A16 native”

1. **`android.os.Oplus*`, `android.view.OplusWindowManager`, ColorOS managers**  
   Live in stock `framework.jar` / `oplus-framework.jar`. On AOSP 16 they are **missing**.  
   Putting A11 `oplus-framework` on `PRODUCT_BOOT_JARS` can soft-brick / bootloop.

2. **~800 OEM class references** (`com.color.support.*`, `com.oplus.*`, …)  
   Many are bundled in the APK; framework ones are not.

3. **`com.oppo.camera.unit.sdk.jar`**  
   A11 `classes.dex` only. No public source to recompile against A16 SDK.

4. **Hidden / non-SDK API**  
   Mitigated by `hidden-api-whitelisted-app`, not by rewriting the app.

## Why not targetSdk 35/36?

Raising targetSdk forces new behavior (FGS types, photo picker, stricter storage, export rules, background starts).  
Without Java source fixes, that usually means **more crashes**, not fewer.

`targetSdk 33` + priv-app + hidden-api whitelist is the usual compromise for OEM camera ports.

## Optional experiments (advanced, at your risk)

```make
# DO NOT enable unless you accept boot risk and have a recovery plan
# PRODUCT_BOOT_JARS += oplus-framework-a11
```

Prefer fixing **NoClassDefFoundError** one-by-one from logcat with thin stubs, not full A11 framework on bootclasspath.

## Rebuild the compat APK later

```bash
# from vendor/oplus/camera after editing compat/work/OppoCamera
apktool b -o /tmp/OppoCamera-unsigned.apk compat/work/OppoCamera
zipalign -f -p 4 /tmp/OppoCamera-unsigned.apk /tmp/OppoCamera-aligned.apk
# sign or let Soong platform-sign via Android.bp
cp /tmp/OppoCamera-aligned.apk priv-app/OppoCamera/OppoCamera.apk
```

## Expected outcome on Infinity-X 16.2

| Goal | Expectation |
|------|-------------|
| APK installs as product priv-app | Yes |
| Launches without instant PackageManager reject | Likely |
| Opens camera / preview | Maybe — device logcat |
| Full ColorOS feature parity | No |
| “Official A16 camera” quality | No — would need A14+ Oplus camera sources or a rewrite |
