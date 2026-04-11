#!/system/bin/sh

# Module directory (where the script is located)
MODDIR=${0%/*}

# This script runs when the device boot is completed
# KernelSU specific stage - runs after boot_completed broadcast

# Logging
LOGFILE="$MODDIR/boot-completed.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

log "================================================"
log "iOS Emoji 18.4 - boot-completed.sh"
log "================================================"

# Detect root manager
if [ "$KSU" = true ]; then
    ROOT_MANAGER="KernelSU"
    # Check for KernelSU Next
    if [ "$KSU_KERNEL_VER_CODE" ] || grep -q "next" /proc/version 2>/dev/null; then
        ROOT_MANAGER="KernelSU-Next"
    fi
elif [ "$APATCH" = true ]; then
    ROOT_MANAGER="APatch"
else
    ROOT_MANAGER="Magisk"
fi

log "Root Manager: $ROOT_MANAGER"
log "Device: $(getprop ro.product.model)"
log "Android: $(getprop ro.build.version.release)"
ANDROID_SDK=$(getprop ro.build.version.sdk)

# Source emoji font path
SOURCE_FONT="$MODDIR/system/fonts/NotoColorEmoji.ttf"

# Function to check if a package is installed
package_installed() {
    pm list packages 2>/dev/null | grep -q "^package:$1$"
    return $?
}

# Function to replace emoji font in app data
replace_app_emoji() {
    local app_name="$1"
    local app_dir="$2"
    local emoji_dir="$3"
    local target_file="$4"
    local target_path="$app_dir/$emoji_dir/$target_file"

    if package_installed "$app_name"; then
        if [ -f "$target_path" ]; then
            if cp "$SOURCE_FONT" "$target_path" 2>/dev/null; then
                chmod 644 "$target_path" 2>/dev/null
                # Restore SELinux context for Android 16 QPR1
                if [ "$ANDROID_SDK" -ge 35 ]; then
                    chcon u:object_r:app_data_file:s0 "$target_path" 2>/dev/null || true
                fi
                log "Replaced emoji font: $app_name"
            else
                log "Failed to replace: $app_name"
            fi
        else
            log "Target not found: $target_path"
        fi
    fi
}

# Check if source font exists
if [ ! -f "$SOURCE_FONT" ]; then
    log "ERROR: Source font not found: $SOURCE_FONT"
    log "================================================"
    exit 1
fi

log "Starting boot-completed emoji replacement..."

# Replace Facebook app emojis (in case service.sh missed any)
replace_app_emoji "com.facebook.orca" "/data/data/com.facebook.orca" "app_ras_blobs" "FacebookEmoji.ttf"
replace_app_emoji "com.facebook.katana" "/data/data/com.facebook.katana" "app_ras_blobs" "FacebookEmoji.ttf"
replace_app_emoji "com.facebook.lite" "/data/data/com.facebook.lite" "files" "emoji_font.ttf"
replace_app_emoji "com.facebook.mlite" "/data/data/com.facebook.mlite" "files" "emoji_font.ttf"

log "boot-completed.sh finished"
log "================================================"

exit 0
