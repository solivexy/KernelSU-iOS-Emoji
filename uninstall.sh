#!/system/bin/sh

# Module directory
MODDIR=${0%/*}

#################
# Detect Root Manager
#################

if [ "$KSU" = true ]; then
    ROOT_MANAGER="KernelSU"
elif [ "$APATCH" = true ]; then
    ROOT_MANAGER="APatch"
else
    ROOT_MANAGER="Magisk"
fi

#################
# Logging
#################

LOGFILE="$MODDIR/uninstall.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
    echo "[*] $1"
}

log "================================================"
log "iOS Emoji 18.4 - Uninstall Script"
log "Root Manager: $ROOT_MANAGER"
log "================================================"

#################
# Configuration
#################

# Facebook app package names
FACEBOOK_APPS="com.facebook.orca com.facebook.katana com.facebook.lite com.facebook.mlite"

# GMS font services
GMS_FONT_PROVIDER="com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider"
GMS_FONT_UPDATER="com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"

#################
# Helper Functions
#################

# Function to check if a package is installed
package_installed() {
    pm list packages 2>/dev/null | grep -q "^package:$1$"
    return $?
}

#################
# Re-enable GMS Font Services
#################

log "INFO: Re-enabling GMS font services..."

if pm enable "$GMS_FONT_PROVIDER" 2>/dev/null; then
    log "INFO: Re-enabled GMS font provider"
else
    log "INFO: Could not re-enable GMS font provider (may already be enabled)"
fi

if pm enable "$GMS_FONT_UPDATER" 2>/dev/null; then
    log "INFO: Re-enabled GMS font updater"
else
    log "INFO: Could not re-enable GMS font updater (may already be enabled)"
fi

#################
# Clear App Caches
#################

log "INFO: Clearing app caches to restore original emojis..."

# Clear Facebook app caches
for app in $FACEBOOK_APPS; do
    if package_installed "$app"; then
        log "INFO: Clearing cache for $app"

        for subpath in /cache /code_cache /app_webview /files/GCache /app_ras_blobs /files; do
            target_dir="/data/data/${app}${subpath}"
            if [ -d "$target_dir" ]; then
                rm -rf "$target_dir" 2>/dev/null
            fi
        done

        # Force stop the app
        am force-stop "$app" 2>/dev/null
        log "INFO: Cleared cache and stopped: $app"
    fi
done

# Clear Gboard cache
if package_installed "com.google.android.inputmethod.latin"; then
    log "INFO: Clearing Gboard cache"

    for subpath in /cache /code_cache; do
        target_dir="/data/data/com.google.android.inputmethod.latin${subpath}"
        if [ -d "$target_dir" ]; then
            rm -rf "$target_dir" 2>/dev/null
        fi
    done

    am force-stop "com.google.android.inputmethod.latin" 2>/dev/null
    log "INFO: Cleared Gboard cache"
fi

#################
# Cleanup Log Files
#################

log "INFO: Cleaning up module files..."

# Remove module log files (except uninstall.log which we're writing to)
rm -f "$MODDIR/service.log"* 2>/dev/null
rm -f "$MODDIR/boot-completed.log"* 2>/dev/null
rm -f "$MODDIR/post-mount.log"* 2>/dev/null

#################
# Completion
#################

log "INFO: Uninstall completed successfully"
log "INFO: Please reboot your device to restore original emojis"
log "================================================"

exit 0
