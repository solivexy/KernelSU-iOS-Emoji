#!/system/bin/sh

# Module directory (where the script is located)
MODDIR=${0%/*}

# This script runs after OverlayFS/modules are mounted
# KernelSU specific stage - runs after metamount.sh completes

# Logging
LOGFILE="$MODDIR/post-mount.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

log "================================================"
log "iOS Emoji 18.4 - post-mount.sh"
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

# Verify that our font was mounted correctly
SYSTEM_FONT="/system/fonts/NotoColorEmoji.ttf"
MODULE_FONT="$MODDIR/system/fonts/NotoColorEmoji.ttf"

# Direct mounting for KernelSU
if [ "$ROOT_MANAGER" = "KernelSU" ] || [ "$ROOT_MANAGER" = "KernelSU-Next" ]; then
    log "Applying direct mount method for $ROOT_MANAGER"
    
    # Mount main emoji font
    if [ -f "$MODULE_FONT" ] && [ -f "$SYSTEM_FONT" ]; then
        if ! mount | grep -q "$SYSTEM_FONT"; then
            # Try nsenter method for KernelSU Next first
            if [ "$ROOT_MANAGER" = "KernelSU-Next" ] && [ -f "/system/bin/nsenter" ]; then
                nsenter -t 1 -m -- mount --bind "$MODULE_FONT" "$SYSTEM_FONT" 2>/dev/null
            else
                mount --bind "$MODULE_FONT" "$SYSTEM_FONT" 2>/dev/null
            fi
            
            if [ $? -eq 0 ]; then
                log "Successfully mounted: $SYSTEM_FONT"
            else
                log "Failed to mount: $SYSTEM_FONT"
            fi
        else
            log "Already mounted: $SYSTEM_FONT"
        fi
    fi
    
    # Mount font variants
    variants="SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf"
    for font in $variants; do
        SYSTEM_VARIANT="/system/fonts/$font"
        MODULE_VARIANT="$MODDIR/system/fonts/$font"
        
        if [ -f "$SYSTEM_VARIANT" ]; then
            # Create variant if it doesn't exist
            if [ ! -f "$MODULE_VARIANT" ]; then
                cp "$MODULE_FONT" "$MODULE_VARIANT" 2>/dev/null
                chmod 644 "$MODULE_VARIANT" 2>/dev/null
            fi
            
            # Mount variant
            if [ -f "$MODULE_VARIANT" ] && ! mount | grep -q "$SYSTEM_VARIANT"; then
                if [ "$ROOT_MANAGER" = "KernelSU-Next" ] && [ -f "/system/bin/nsenter" ]; then
                    nsenter -t 1 -m -- mount --bind "$MODULE_VARIANT" "$SYSTEM_VARIANT" 2>/dev/null
                else
                    mount --bind "$MODULE_VARIANT" "$SYSTEM_VARIANT" 2>/dev/null
                fi
                
                if [ $? -eq 0 ]; then
                    log "Mounted variant: $font"
                fi
            fi
        fi
    done
else
    log "Non-KernelSU root manager, relying on native mount system"
fi

# Verify mount status
if [ -f "$SYSTEM_FONT" ]; then
    SYSTEM_SIZE=$(stat -c%s "$SYSTEM_FONT" 2>/dev/null || echo "0")
    MODULE_SIZE=$(stat -c%s "$MODULE_FONT" 2>/dev/null || echo "0")

    if [ "$SYSTEM_SIZE" = "$MODULE_SIZE" ] && [ "$MODULE_SIZE" != "0" ]; then
        log "Font mounted successfully (size: $SYSTEM_SIZE bytes)"
    else
        log "Font mount verification: system=$SYSTEM_SIZE, module=$MODULE_SIZE"
    fi
else
    log "System font path not accessible"
fi

log "post-mount.sh completed"
log "================================================"

exit 0
