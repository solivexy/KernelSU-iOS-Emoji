#!/system/bin/sh

# Module directory (where the script is located)
MODDIR=${0%/*}

#################
# Detect Root Manager
#################

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

#################
# Logging Configuration
#################

LOGFILE="$MODDIR/service.log"
MAX_LOG_SIZE=$((5 * 1024 * 1024)) # 5 MB
MAX_LOG_FILES=3
MAX_LOG_AGE_DAYS=7

# Ensure the module directory exists
mkdir -p "$MODDIR"

# Logging function
log() {
    # Delete old log files
    find "$MODDIR" -name "$(basename "$LOGFILE")*" -type f -mtime +$MAX_LOG_AGE_DAYS -delete 2>/dev/null

    # Check if log file exists and is too large
    if [ -f "$LOGFILE" ]; then
        local log_size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo 0)
        if [ "$log_size" -gt "$MAX_LOG_SIZE" ]; then
            # Rotate logs
            for i in $(seq $MAX_LOG_FILES -1 1); do
                [ -f "$LOGFILE.$i" ] && mv "$LOGFILE.$i" "$LOGFILE.$((i+1))" 2>/dev/null
            done
            mv "$LOGFILE" "$LOGFILE.1" 2>/dev/null
        fi
    fi

    # Create log message
    local log_message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$log_message" >> "$LOGFILE"

    # Display simplified message to user (for action.sh)
    echo "[*] $(echo "$1" | sed 's/^[A-Z]*: //')"
}

#################
# Configuration
#################

# Facebook app package names
FACEBOOK_APPS="com.facebook.orca com.facebook.katana com.facebook.lite com.facebook.mlite"

# GMS font services
GMS_FONT_PROVIDER="com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider"
GMS_FONT_UPDATER="com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"

# Paths
DATA_FONTS_DIR="/data/fonts"
SOURCE_FONT="$MODDIR/system/fonts/NotoColorEmoji.ttf"

#################
# Helper Functions
#################

# Function to check if a package is installed
package_installed() {
    pm list packages 2>/dev/null | grep -q "^package:$1$"
    return $?
}

# Function to check if a service/component exists
service_exists() {
    pm list packages 2>/dev/null | grep -q "$(echo "$1" | cut -d'/' -f1)"
    return $?
}

#################
# Script Header
#################

log "================================================"
log "iOS Emoji 18.4 - service.sh"
log "Root Manager: $ROOT_MANAGER"
log "Brand: $(getprop ro.product.brand)"
log "Device: $(getprop ro.product.model)"
log "Android Version: $(getprop ro.build.version.release)"
log "SDK Version: $(getprop ro.build.version.sdk)"
ANDROID_SDK=$(getprop ro.build.version.sdk)
log "================================================"

#################
# Wait for Boot
#################

# Wait until the device has completed booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done

# Wait until the /sdcard directory is available
while [ ! -d /sdcard ]; do
    sleep 5
done

log "INFO: Service started via $ROOT_MANAGER"

#################
# Manual Mount for KernelSU
#################

if [ "$KSU" = true ]; then
    log "INFO: Verifying KernelSU direct mounts"
    
    SOURCE_FONT_FILE="$MODDIR/system/fonts/NotoColorEmoji.ttf"
    TARGET_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"
    
    if [ -f "$SOURCE_FONT_FILE" ] && [ -f "$TARGET_FONT_FILE" ]; then
        if ! mount | grep -q "$TARGET_FONT_FILE"; then
            log "INFO: Mounting system font directly"
            
            # Try nsenter method for KernelSU Next
            if [ "$ROOT_MANAGER" = "KernelSU-Next" ] && [ -f "/system/bin/nsenter" ]; then
                log "INFO: Using nsenter method for KernelSU Next"
                nsenter -t 1 -m -- mount --bind "$SOURCE_FONT_FILE" "$TARGET_FONT_FILE" 2>/dev/null
            else
                mount --bind "$SOURCE_FONT_FILE" "$TARGET_FONT_FILE" 2>/dev/null
            fi
            
            if [ $? -eq 0 ]; then
                chmod 644 "$TARGET_FONT_FILE" 2>/dev/null
                log "INFO: Successfully mounted system emoji font"
            else
                log "WARN: Direct mount failed, font may not appear"
            fi
        else
            log "INFO: System font already mounted"
        fi
    fi
fi

#################
# Font Replacement
#################

replace_emoji_fonts() {
    log "INFO: Starting emoji replacement process..."

    # Check if the source emoji font exists
    if [ ! -f "$SOURCE_FONT" ]; then
        log "ERROR: Source emoji font not found: $SOURCE_FONT"
        return 1
    fi

    log "INFO: Source font found ($(stat -c%s "$SOURCE_FONT" 2>/dev/null || echo "unknown") bytes)"

    # Find all .ttf files containing "Emoji" in their names
    local emoji_fonts=$(find /data/data -iname "*emoji*.ttf" -type f 2>/dev/null)

    if [ -z "$emoji_fonts" ]; then
        log "INFO: No emoji fonts found in app data. Skipping."
        return 0
    fi

    # Replace each emoji font with the custom font
    echo "$emoji_fonts" | while read font; do
        [ -z "$font" ] && continue

        # Skip if file doesn't exist or isn't writable
        if [ ! -f "$font" ]; then
            continue
        fi

        log "INFO: Replacing emoji font: $font"

        if cp "$SOURCE_FONT" "$font" 2>/dev/null; then
            chmod 644 "$font" 2>/dev/null
            # Restore SELinux context for Android 16 QPR1
            if [ "$ANDROID_SDK" -ge 35 ]; then
                chcon u:object_r:system_file:s0 "$font" 2>/dev/null || true
            fi
            log "INFO: Successfully replaced: $font"
        else
            log "ERROR: Failed to replace: $font"
        fi
    done

    log "INFO: Emoji replacement process completed"
}

#################
# Main Execution
#################

# Run font replacement
replace_emoji_fonts

# Force-stop Facebook apps after all replacements are done
log "INFO: Force-stopping Facebook apps..."
for app in $FACEBOOK_APPS; do
    if package_installed "$app"; then
        if am force-stop "$app" 2>/dev/null; then
            log "INFO: Force-stopped: $app"
        else
            log "WARN: Could not force-stop: $app"
        fi
    fi
done

# Small delay to allow system to process
sleep 2

#################
# Disable GMS Font Services
#################

if service_exists "com.google.android.gms"; then
    log "INFO: Attempting to disable GMS font services..."

    # Try to disable font provider
    if pm disable "$GMS_FONT_PROVIDER" 2>/dev/null; then
        log "INFO: Disabled GMS font provider"
    else
        log "INFO: Could not disable GMS font provider (may require additional permissions)"
    fi

    # Try to disable font updater
    if pm disable "$GMS_FONT_UPDATER" 2>/dev/null; then
        log "INFO: Disabled GMS font updater"
    else
        log "INFO: Could not disable GMS font updater (may require additional permissions)"
    fi
else
    log "INFO: GMS not found, skipping font service disable"
fi

#################
# Cleanup
#################

# Clean up /data/fonts directory (Android 12+)
log "INFO: Cleaning up leftover font files..."
if [ -d "$DATA_FONTS_DIR" ]; then
    if rm -rf "$DATA_FONTS_DIR" 2>/dev/null; then
        log "INFO: Removed: $DATA_FONTS_DIR"
    else
        log "WARN: Could not remove: $DATA_FONTS_DIR"
    fi
else
    log "INFO: No /data/fonts directory found"
fi

# Android 16 QPR1: Clear font cache
if [ "$ANDROID_SDK" -ge 35 ]; then
    log "INFO: Android 16+ detected, clearing system font cache"
    rm -rf /data/system/theme/fonts 2>/dev/null && log "INFO: Cleared theme font cache"
    rm -rf /data/system/users/*/fonts 2>/dev/null && log "INFO: Cleared user font cache"
fi

#################
# Completion
#################

log "INFO: Service completed successfully"
log "================================================"

exit 0
