#!/usr/bin/env bash
#
# Extract stock RUI F.14 OPlus/Oppo camera assets into this repository.
#
# Usage:
#   ./scripts/extract-from-f14-dump.sh /path/to/RUI_F-14_Global_full_dump
#
set -euo pipefail

DUMP="${1:-}"
if [[ -z "${DUMP}" || ! -d "${DUMP}" ]]; then
  echo "Usage: $0 /path/to/RUI_F-14_Global_full_dump"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "[*] Camera port root: ${ROOT}"
echo "[*] Dump: ${DUMP}"

mkdir -p \
  "${ROOT}/priv-app/OppoCamera" \
  "${ROOT}/framework" \
  "${ROOT}/lib64/odm" \
  "${ROOT}/etc/camera" \
  "${ROOT}/etc/permissions" \
  "${ROOT}/etc/sysconfig" \
  "${ROOT}/etc/default-permissions"

# APK
APK_SRC="${DUMP}/system/my_stock/app/OppoCamera/OppoCamera.apk"
if [[ ! -f "${APK_SRC}" ]]; then
  # alternate layouts
  APK_SRC="$(find "${DUMP}" -path '*/OppoCamera/OppoCamera.apk' | head -1 || true)"
fi
[[ -f "${APK_SRC}" ]] || { echo "OppoCamera.apk not found"; exit 1; }
cp -a "${APK_SRC}" "${ROOT}/priv-app/OppoCamera/OppoCamera.apk"
echo "[+] OppoCamera.apk ($(du -h "${ROOT}/priv-app/OppoCamera/OppoCamera.apk" | cut -f1))"

# Unit SDK
SDK_JAR="$(find "${DUMP}" -name 'com.oppo.camera.unit.sdk.jar' | head -1 || true)"
[[ -n "${SDK_JAR}" ]] && cp -a "${SDK_JAR}" "${ROOT}/framework/" && echo "[+] com.oppo.camera.unit.sdk.jar"

# system_ext helper
for so in libopluscameraservice.so; do
  f="$(find "${DUMP}/system" -path "*/lib64/${so}" 2>/dev/null | head -1 || true)"
  [[ -n "${f}" ]] && cp -a "${f}" "${ROOT}/lib64/" && echo "[+] ${so}"
done

# Critical ODM libs
LIBS=(
  libapsjpeg.so libapsexif.so libstblur_api.so
  libFaceBeautyCap.so libFaceBeautyPre.so
  libbsproxy.so libPolarrRender.so
  libWaterMode.so libTrafficMode.so libwatermark_photo.so
)
for lib in "${LIBS[@]}"; do
  if [[ -f "${DUMP}/odm/lib64/${lib}" ]]; then
    cp -a "${DUMP}/odm/lib64/${lib}" "${ROOT}/lib64/odm/"
    echo "[+] odm/lib64/${lib}"
  else
    echo "[!] missing ${lib}"
  fi
done

# Full camera etc
if [[ -d "${DUMP}/odm/etc/camera" ]]; then
  rsync -a "${DUMP}/odm/etc/camera/" "${ROOT}/etc/camera/"
  echo "[+] odm/etc/camera ($(find "${ROOT}/etc/camera" -type f | wc -l) files)"
fi

echo "[*] Done. Include vendor/oplus/camera/camera.mk from device.mk"
