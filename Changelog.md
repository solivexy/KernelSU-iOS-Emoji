# Changelog

## v26.4 (Current Release)

### 🚀 Major Changes
- **KernelSU Next Support**: Full compatibility with KernelSU Next
- **Android 16 QPR1 Support**: Fully tested and optimized for Android 16 QPR1
- **No Metamodule Required**: Direct mounting implementation eliminates metamodule dependency
- **Enhanced Mounting**: Uses nsenter method for KernelSU Next, bind mount for others

### ✨ New Features
- **KernelSU Next Detection**: Automatically detects and optimizes for KernelSU Next
- **SELinux Context Support**: Restores proper SELinux contexts on Android 16+ (SDK 35+)
- **Direct Mounting**: Implements direct bind mounting in `post-mount.sh` and `service.sh`
- **Android 16 Font Cache Clearing**: Clears `/data/system/theme/fonts` and user font caches
- **SDK Version Detection**: Runtime detection for Android version-specific optimizations

### 🔧 Improvements
- Removed all metamodule dependencies and warnings
- Simplified installation process (no prerequisites)
- Enhanced `post-mount.sh` with direct mounting logic
- Enhanced `service.sh` with nsenter support for KernelSU Next
- Enhanced `boot-completed.sh` with SELinux context restoration
- Updated `customize.sh` to detect KernelSU Next
- Module version updated to v26.4 (versionCode 26400)

### 🐛 Bug Fixes
- Fixed font mounting issues on KernelSU without metamodule
- Fixed SELinux context issues on Android 16+
- Fixed font cache persistence on Android 16 QPR1

### 📝 Documentation
- Updated README to remove metamodule requirements
- Added KernelSU Next to supported root managers
- Updated compatibility section for Android 16 QPR1
- Simplified installation instructions
- Updated troubleshooting guide

---

## v26.4 (KernelSU Edition)

### 🚀 Major Changes
- **KernelSU Support**: Full compatibility with KernelSU root manager
- **APatch Support**: Added support for APatch root manager
- **Multi-Root Manager**: Module auto-detects root manager (KernelSU/Magisk/APatch)

### ✨ New Features
- Added `post-mount.sh` for KernelSU post-mount stage
- Added `boot-completed.sh` for KernelSU boot-completed stage
- Added `uninstall.sh` for proper cleanup on module removal
- Added `action.sh` for manual emoji refresh from manager app

### 🎨 Emoji Updates
- Updated to iOS 26.4 Emojis ([Unicode 16.0](https://emojipedia.org/unicode-16.0))
- Thanks to [samuelngs/apple-emoji-linux](https://github.com/samuelngs/apple-emoji-linux) for the emoji font source

### 🔧 Improvements
- Improved error handling with proper stderr redirection
- Enhanced logging system with log rotation
- Better root manager detection using `$KSU` and `$APATCH` variables
- Updated `update.json` for KernelSU update mechanism
- Restructured scripts following KernelSU module guidelines
- Use `MODDIR` instead of `MODPATH` for consistency

### 📝 Documentation
- Updated README with KernelSU installation instructions
- Added troubleshooting guide for KernelSU users
- Updated FAQ with KernelSU-specific questions

---

## v17.4.7

### New Features
- **Facebook Lite/Messenger Lite Support**
  - Added emoji replacement compatibility for:
    - Facebook Lite (`com.facebook.lite`)
    - Messenger Lite (`com.facebook.mlite`)
- **`display_name()` function**
  - Added function to display app names instead of package name

### Improvements
- **Case-Insensitive Font Detection**
  - Modified `replace_emoji_fonts()` in `service.sh` to use `find -iname "*emoji*.ttf"` instead of case-sensitive matching
- **Cache Clearing Optimization**
  - Rewrote `clear_cache()` to eliminate delays caused by recursive `find` in `/data`
  - New implementation uses direct path targeting for faster cleanup

---

## v17.4.6

- Updated `META-INF` structure
- Restructured `customize.sh` code for easier maintenance
- Added `service.sh` for automatic emoji replacement on boot
- Eliminated the need for manual troubleshooting steps

---

## v17.4.1

- Added Magisk 27005+ Support (thanks to [E85Addict](https://github.com/E85Addict))
- Added OverlayFS Support (thanks to [reddxae](https://github.com/reddxae))
- Moved from `install.sh` to `customize.sh` as recommended by [Magisk Docs](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md)

---

## v17.4

- Added iOS 17.4 Emojis
- Added Gboard cache clearing process

---

## v16.4

- Added iOS 16.4 Emojis
- Fixed typo in installation script

---

## v15.4.6

- Added Android 12 Support
- Fixed typo in extraction process
- Added Android 13 Support

---

## v15.4.5

- Removed method to replace Google Keyboard emojis (was conflicting with other apps)

---

## v15.4.4

- Added missing XML file to module
- Fixed typo

---

## v15.4.3

- Merged normal module and Samsung module into one
- Fixed incorrect directory path in install file
- Added compatibility for LG and HTC devices

---

## v15.4.2

- Added method to replace Google Keyboard emojis
- Tested `updater.json` directly from Magisk Manager

---

## v15.4.1

- Added `updater.json` for direct updates from Magisk Manager
- Code cleanup

---

## v15.4

- Added iOS 15.4 Emojis

---

## v14.6

- Added iOS 14.6 Emojis
- Added Facebook and Messenger emoji replacement

---

## v14.2

- Initial release
- Added iOS 14.2 Emojis
- Fixed naming error on Samsung devices