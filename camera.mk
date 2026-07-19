#
# RMX1931 (samurai) — Stock RUI F.14 OPlus/Oppo Camera product makefile
#
# Full-tree path: vendor/oplus/camera
# Include from device.mk:
#   $(call inherit-product-if-exists, vendor/oplus/camera/camera.mk)
#

LOCAL_CAMERA_PATH := $(dir $(lastword $(MAKEFILE_LIST)))

PRODUCT_SOONG_NAMESPACES += \
    vendor/oplus/camera

# Stock app toggle (HAL supplemental assets always apply)
TARGET_USES_OPLUS_CAMERA ?= true

# =============================================================================
# Always: algo libs missing from historical proprietary extract
# libAlgoProcess NEEDED → libapsjpeg, libapsexif, libbsproxy, …
#
# Installed under /vendor (not /odm): ODM partition is only 256MB and these
# libs alone are ~40MB. Vendor has ample free space; libs have no hardcoded
# /odm paths (models/configs stay under /odm/etc/camera).
# libstblur_api.so is already listed in vendor public.libraries.txt.
# =============================================================================
PRODUCT_COPY_FILES += \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libapsjpeg.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libapsjpeg.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libapsexif.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libapsexif.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libstblur_api.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libstblur_api.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libFaceBeautyCap.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libFaceBeautyCap.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libFaceBeautyPre.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libFaceBeautyPre.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libbsproxy.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libbsproxy.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libPolarrRender.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libPolarrRender.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libWaterMode.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libWaterMode.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libTrafficMode.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libTrafficMode.so \
    $(LOCAL_CAMERA_PATH)/lib64/odm/libwatermark_photo.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libwatermark_photo.so

# Supplemental F.14 camera assets (base sensor configs already in vendor/realme/samurai)
# MUST stay on ODM: stock camera/algo blobs hardcode /odm/etc/camera/...
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/darksight,$(TARGET_COPY_OUT_ODM)/etc/camera/darksight) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/fb_model,$(TARGET_COPY_OUT_ODM)/etc/camera/fb_model) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/filters_lut,$(TARGET_COPY_OUT_ODM)/etc/camera/filters_lut) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/filters_res,$(TARGET_COPY_OUT_ODM)/etc/camera/filters_res) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/megvii,$(TARGET_COPY_OUT_ODM)/etc/camera/megvii) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/singleblur,$(TARGET_COPY_OUT_ODM)/etc/camera/singleblur) \
    $(call find-copy-subdir-files,*,$(LOCAL_CAMERA_PATH)/etc/camera/tonemap,$(TARGET_COPY_OUT_ODM)/etc/camera/tonemap)

# =============================================================================
# Optional: stock OppoCamera application stack
# =============================================================================
ifeq ($(TARGET_USES_OPLUS_CAMERA),true)

PRODUCT_PACKAGES += \
    OppoCamera \
    com.oppo.camera.unit.sdk \
    permissions_com.oppo.camera.unit.sdk \
    privapp_whitelist_com.oppo.camera \
    hiddenapi_whitelist_com.oppo.camera \
    libopluscameraservice

PRODUCT_PROPERTY_OVERRIDES += \
    ro.oplus.system.camera.name=com.oppo.camera \
    ro.com.google.lens.oem_camera_package=com.oppo.camera \
    vendor.camera.aux.packagelist=android,com.android.camera,com.oppo.camera,org.codeaurora.snapcam \
    persist.vendor.camera.privapp.list=com.oppo.camera,org.codeaurora.snapcam \
    persist.camera.privapp.list=com.oppo.camera,org.codeaurora.snapcam

PRODUCT_COPY_FILES += \
    $(LOCAL_CAMERA_PATH)/etc/default-permissions/default-permissions-com.oppo.camera.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions-com.oppo.camera.xml

endif # TARGET_USES_OPLUS_CAMERA
