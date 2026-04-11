##########################################################################################
#
# KernelSU / Magisk / APatch Module Installer Script
# iOS 18.4 Emoji Font Module
#
##########################################################################################
#!/system/bin/sh

# Script Details
SKIPUNZIP=1

#################
# Detect Root Manager
#################

if [ "$KSU" = true ]; then
    ui_print "- KernelSU detected"
    ui_print "- KernelSU version: $KSU_VER ($KSU_VER_CODE)"
    ROOT_MANAGER="KernelSU"
    
    # Check for KernelSU Next
    if [ "$KSU_KERNEL_VER_CODE" ] || grep -q "next" /proc/version 2>/dev/null; then
        ui_print "- KernelSU Next detected"
        KSU_NEXT=true
    fi
elif [ "$APATCH" = true ]; then
    ui_print "- APatch detected"
    ui_print "- APatch version: $APATCH_VER ($APATCH_VER_CODE)"
    ROOT_MANAGER="APatch"
else
    ui_print "- Magisk detected"
    ui_print "- Magisk version: $MAGISK_VER ($MAGISK_VER_CODE)"
    ROOT_MANAGER="Magisk"
fi

ui_print "*******************************"
ui_print "*     iOS Emoji 18.4          *"
ui_print "*     $ROOT_MANAGER Edition   *"
ui_print "*******************************"

#################
# Definitions
#################

FONT_DIR="$MODPATH/system/fonts"
FONT_EMOJI="NotoColorEmoji.ttf"
SYSTEM_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"

#################
# Functions
#################

# Function to check if a package is installed
package_installed() {
    pm list packages 2>/dev/null | grep -q "^package:$1$"
    return $?
}

# Function to set user-friendly app name
display_name() {
    case "$1" in
        "com.facebook.orca") echo "Messenger" ;;
        "com.facebook.katana") echo "Facebook" ;;
        "com.facebook.lite") echo "Facebook Lite" ;;
        "com.facebook.mlite") echo "Messenger Lite" ;;
        "com.google.android.inputmethod.latin") echo "Gboard" ;;
        *) echo "$1" ;;
    esac
}

# Function to mount a font file
mount_font() {
    local source="$1"
    local target="$2"

    [ ! -f "$source" ] && return 1

    local target_dir=$(dirname "$target")
    [ ! -d "$target_dir" ] && return 1

    mkdir -p "$(dirname "$target")" 2>/dev/null

    if mount -o bind "$source" "$target" 2>/dev/null; then
        chmod 644 "$target" 2>/dev/null
        return 0
    fi
    return 1
}

# Function to replace emojis for a specific app
replace_emojis() {
    local app_name="$1"
    local app_dir="$2"
    local emoji_dir="$3"
    local target_filename="$4"
    local app_display_name=$(display_name "$app_name")

    if package_installed "$app_name"; then
        ui_print "- Detected: $app_display_name"
        if mount_font "$FONT_DIR/$FONT_EMOJI" "$app_dir/$emoji_dir/$target_filename"; then
            ui_print "- Emojis mounted: $app_display_name"
        fi
    else
        ui_print "- Not installed: $app_display_name"
    fi
}

# Function to clear app cache
clear_cache() {
    local app_name="$1"
    local app_display_name=$(display_name "$app_name")

    if ! package_installed "$app_name"; then
        return 0
    fi

    ui_print "- Cleaning cache: $app_display_name"

    for subpath in /cache /code_cache /app_webview /files/GCache; do
        target_dir="/data/data/${app_name}${subpath}"
        [ -d "$target_dir" ] && rm -rf "$target_dir" 2>/dev/null
    done

    am force-stop "$app_name" 2>/dev/null
    ui_print "- Cache cleared: $app_display_name"
}

#################
# Installation
#################

ui_print "- Extracting module files"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2 || {
    ui_print "! Failed to extract module files"
    abort "! Installation failed"
}

# Create fonts directory if not exists
mkdir -p "$FONT_DIR"

# Extract font file specifically
unzip -o "$ZIPFILE" 'system/fonts/*' -d "$MODPATH" >&2

# Verify font file exists
if [ ! -f "$FONT_DIR/$FONT_EMOJI" ]; then
    ui_print "! Font file not found after extraction"
    abort "! Installation failed"
fi

ui_print "- Installing Emojis"

# Replace system emoji font variants
variants="SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf"

for font in $variants; do
    if [ -f "/system/fonts/$font" ]; then
        if cp "$FONT_DIR/$FONT_EMOJI" "$FONT_DIR/$font" 2>/dev/null; then
            ui_print "- Replaced variant: $font"
        fi
    fi
done

# Mount system emoji font (for immediate effect)
if [ -f "$FONT_DIR/$FONT_EMOJI" ]; then
    if mount_font "$FONT_DIR/$FONT_EMOJI" "$SYSTEM_FONT_FILE"; then
        ui_print "- System font mounted successfully"
    else
        ui_print "- System font will be applied after reboot"
    fi
fi

# Replace Facebook and Messenger emojis
ui_print "- Processing Facebook apps"
replace_emojis "com.facebook.orca" "/data/data/com.facebook.orca" "app_ras_blobs" "FacebookEmoji.ttf"
clear_cache "com.facebook.orca"

replace_emojis "com.facebook.katana" "/data/data/com.facebook.katana" "app_ras_blobs" "FacebookEmoji.ttf"
clear_cache "com.facebook.katana"

# Replace Lite app emojis
replace_emojis "com.facebook.lite" "/data/data/com.facebook.lite" "files" "emoji_font.ttf"
clear_cache "com.facebook.lite"

replace_emojis "com.facebook.mlite" "/data/data/com.facebook.mlite" "files" "emoji_font.ttf"
clear_cache "com.facebook.mlite"

# Clear Gboard cache if installed
ui_print "- Processing Gboard"
clear_cache "com.google.android.inputmethod.latin"

# Remove /data/fonts directory for Android 12+
if [ -d "/data/fonts" ]; then
    rm -rf "/data/fonts"
    ui_print "- Removed existing /data/fonts directory"
fi

# Android 16 QPR1: Additional font cache cleanup
ANDROID_SDK=$(getprop ro.build.version.sdk)
if [ "$ANDROID_SDK" -ge 35 ]; then
    ui_print "- Android 16+ detected, clearing font caches"
    rm -rf /data/system/theme/fonts 2>/dev/null
    rm -rf /data/system/users/*/fonts 2>/dev/null
fi

# Handle fonts.xml symlinks for emoji font family
FONTS=/system/etc/fonts.xml
if [ -f "$FONTS" ]; then
    FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' "$FONTS" 2>/dev/null)
    for font in $FONTFILES; do
        if [ -n "$font" ] && [ "$font" != "$FONT_EMOJI" ]; then
            ln -sf /system/fonts/NotoColorEmoji.ttf "$MODPATH/system/fonts/$font" 2>/dev/null
        fi
    done
fi

#################
# Permissions
#################

ui_print "- Setting permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm_recursive "$FONT_DIR" 0 0 0755 0644

#################
# OverlayFS Support (Magisk only)
#################

if [ "$ROOT_MANAGER" = "Magisk" ]; then
    OVERLAY_IMAGE_EXTRA=0
    OVERLAY_IMAGE_SHRINK=true

    if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
        /data/adb/modules/magisk_overlayfs/overlayfs_system --test 2>/dev/null; then
        ui_print "- Adding OverlayFS support"
        . /data/adb/modules/magisk_overlayfs/util_functions.sh
        support_overlayfs && rm -rf "$MODPATH/system"
    fi
fi

#################
# Completion
#################

ui_print ""
ui_print "- Installation completed successfully!"
ui_print "- Reboot your device to apply changes."
ui_print ""
ui_print "- Enjoy your new iOS emojis! :)"
