#!/system/bin/sh
MODDIR="${0%/*}"

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
# Header
#################

echo ""
echo "================================"
echo "  iOS Emoji 18.4 - Action"
echo "  Root Manager: $ROOT_MANAGER"
echo "================================"
echo ""

#################
# Validate Script
#################

SCRIPT="$MODDIR/service.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: Missing service.sh"
    echo "The module may be corrupted. Please reinstall."
    exit 1
fi

#################
# Execute Service Script
#################

echo "Running emoji replacement service..."
echo ""

if sh "$SCRIPT"; then
    echo ""
    echo "================================"
    echo "  Operation completed!"
    echo "================================"
    echo ""
    echo "If emojis don't appear correctly,"
    echo "please reboot your device."
    echo ""
    exit 0
else
    echo ""
    echo "================================"
    echo "  ERROR: Operation failed!"
    echo "================================"
    echo ""
    echo "Check $MODDIR/service.log for details."
    echo ""
    exit 1
fi
