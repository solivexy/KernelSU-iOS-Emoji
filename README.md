# KernelSU-iOS-Emoji

Systemlessly replaces the emoji font with iOS 26.4 Emoji.

**Compatible with KernelSU, KernelSU Next, Magisk, and APatch.**

**✨ No metamodule required! Direct mounting support for all platforms.**

[![Stars](https://img.shields.io/github/stars/solivexy/KernelSU-iOS-Emoji?label=Stars&color=blue)](https://github.com/solivexy/KernelSU-iOS-Emoji)
[![Release](https://img.shields.io/github/v/release/solivexy/KernelSU-iOS-Emoji?label=Release&logo=github)](https://github.com/solivexy/KernelSU-iOS-Emoji/releases/latest)
[![Download](https://img.shields.io/github/downloads/solivexy/KernelSU-iOS-Emoji/total?label=Downloads&logo=github)](https://github.com/solivexy/KernelSU-iOS-Emoji/releases/)

> [!TIP]
> Contributions are welcome! If you'd like to help improve this module, feel free to submit a pull request. Check out the [Contributing](#contributing) section for more details.

## Supported Root Managers

| Root Manager | Status | Minimum Version |
|--------------|--------|-----------------|
| KernelSU Next | ✅ Supported | Latest |
| KernelSU     | ✅ Supported | v0.6.0+ |
| Magisk       | ✅ Supported | v24.0+  |
| APatch       | ✅ Supported | v10300+ |

## Installation

### KernelSU / KernelSU Next

1. Download the latest release from the [Releases page](https://github.com/solivexy/KernelSU-iOS-Emoji/releases/latest)
2. Open the KernelSU Manager app
3. Go to **Modules** → tap the **Install** button (➕) and select the downloaded ZIP file
4. Reboot your device
5. Enjoy iOS emojis system-wide!

> **Note:** No metamodule required! The module uses direct mounting for full compatibility.

### Magisk

1. Download the latest release from the [Releases page](https://github.com/solivexy/KernelSU-iOS-Emoji/releases/latest)
2. Open the Magisk app
3. Go to **Modules** → **Install from storage** and select the downloaded ZIP file
4. Reboot your device
5. Enjoy iOS emojis system-wide!

### APatch

1. Download the latest release from the [Releases page](https://github.com/solivexy/KernelSU-iOS-Emoji/releases/latest)
2. Open the APatch app
3. Go to **Modules** → tap the **Install** button and select the downloaded ZIP file
4. Reboot your device
5. Enjoy iOS emojis system-wide!

## Compatibility

- **Android Version**: Android 10 - 16 QPR1 (Fully tested and optimized)
- **SELinux**: Works with enforcing mode (Android 16+ SELinux context support)
- **Devices**: Works on most devices including Samsung, LG, HTC, OnePlus, Pixel, and more.

## Screenshot

<img src="https://github.com/solivexy/KernelSU-iOS-Emoji/blob/main/iOS_Emoji_Screenshot.jpg" alt="iOS Emojis on Android" width="400" />

*Example of iOS emojis displayed on an Android device.*

## Features

- 🍎 **iOS 26.4 Emojis** - Latest Unicode 16.0 emoji set
- 🔄 **Multi-Root Manager Support** - KernelSU, KernelSU Next, Magisk, and APatch
- 🚀 **No Metamodule Required** - Direct mounting without dependencies
- 🤖 **Android 16 QPR1 Ready** - Full SELinux context support
- 📱 **Facebook/Messenger Support** - Replaces emojis in Facebook apps
- ⌨️ **Gboard Compatible** - Works with Google Keyboard
- 🔧 **Action Button** - Manual emoji refresh from manager app
- 📝 **Detailed Logging** - Service logs for troubleshooting

## Module Scripts

This module includes the following scripts that run at different boot stages:

| Script | Stage | Purpose |
|--------|-------|---------|
| `service.sh` | late_start service | Direct mounting, emoji replacement, GMS disable |
| `post-mount.sh` | post-mount | Direct font mounting (KernelSU/KernelSU Next) |
| `boot-completed.sh` | boot-completed | Final emoji replacement with SELinux context |
| `action.sh` | Manual trigger | User-triggered emoji refresh |
| `uninstall.sh` | Module removal | Cleanup and restore settings |

## Changelog

### v26.4 (Current)
- **KernelSU Next Support**
  - Added KernelSU Next detection and compatibility
  - Implemented nsenter mounting method for KernelSU Next
  - Direct mounting support (no metamodule required)
- **Android 16 QPR1 Support**
  - Added SELinux context restoration for Android 16+
  - Enhanced font cache clearing for Android 16
  - SDK version detection (Android 10-16 QPR1)
- **Removed Metamodule Dependency**
  - Direct bind mounting implementation
  - Works without meta-overlayfs
  - Simplified installation process

### v26.4 (KernelSU Edition)
- **KernelSU & APatch Support**
  - Ported module for full KernelSU compatibility
  - Added APatch support
  - Module now auto-detects root manager (KernelSU/Magisk/APatch)
- Added iOS 26.4 Emojis ([Unicode 16.0](https://emojipedia.org/unicode-16.0))
- Added `post-mount.sh` for KernelSU post-mount stage
- Added `boot-completed.sh` for KernelSU boot-completed stage
- Added `uninstall.sh` for proper cleanup on module removal
- Improved error handling and logging
- Updated `update.json` for KernelSU update mechanism

<details>
<summary>Click to view prior changelogs</summary>

### v17.4.7
- **Facebook Lite/Messenger Lite Support**
  - Added emoji replacement for Facebook Lite and Messenger Lite
- **Case-Insensitive Font Detection**
- **Cache Clearing Optimization**

### v17.4.6
- Updated `META-INF`
- Restructured `customize.sh` code
- Added `service.sh` for automatic emoji replacement

### v17.4.1
- Added Magisk 27005+ Support
- Added OverlayFS Support
- Moved to `customize.sh`

### v17.4
- Added 17.4 Emojis

### v16.4
- Added 16.4 Emojis

### v15.4.6
- Added Android 12/13 Support

</details>

## Changelog for Emojis

- [26.4 New Emojis](https://blog.emojipedia.org/apple-ios-26-4-emoji-changelog/)
- [17.4 New Emojis](https://blog.emojipedia.org/ios-17-4-emoji-changelog/)
- [16.4 New Emojis](https://blog.emojipedia.org/ios-16-4-emoji-changelog/)
- [15.4 New Emojis](https://blog.emojipedia.org/ios-15-4-emoji-changelog/)

## FAQ

### Q: Why aren't the emojis changing after installation?

**A:** There are several things to check:

1. Ensure the module is enabled in your root manager
2. Reboot your device
3. Clear the cache of your keyboard app (e.g., Gboard)
4. Check logs in `/data/adb/modules/iOS_Emoji/service.log`
5. Try using the Action button in the module to manually refresh

### Q: Does this work with third-party keyboards?

**A:** Yes, the module replaces the system emoji font, so it should work with any keyboard that uses system emojis.

### Q: Can I use this alongside other modules?

**A:** Yes, but conflicts may arise if another module modifies the system font. Disable conflicting modules if issues occur.

### Q: What's the difference between KernelSU and Magisk versions?

**A:** This module is compatible with both! The same ZIP file works for KernelSU, Magisk, and APatch. The installation script automatically detects which root manager you're using.

### Q: The Action button doesn't work. What should I do?

**A:** The Action button runs `service.sh` manually. If it fails:
1. Check `service.log` in the module directory for errors
2. Make sure the module is properly installed
3. Try rebooting your device

## Tested On

- OnePlus 13 (Android 15, 16)
- OnePlus 11 (Android 14, 15)
- OnePlus 8T (Android 13)
- OnePlus 6
- Pixel 7 Pro (Android 15, 16)
- [Reported working by users](https://github.com/solivexy/KernelSU-iOS-Emoji/issues?q=is%3Aissue+is%3Aclosed+label%3A%22reported+working%22)

## Troubleshooting

### General Issues
- Reboot your device after installation
- Clear keyboard app cache (Settings → Apps → Gboard → Clear Cache)
- Use the Action button in the module to manually refresh emojis

### KernelSU / KernelSU Next Specific Issues
- Ensure the module is enabled in KernelSU Manager
- For KernelSU Next: Module automatically uses nsenter mounting method
- View logs: `/data/adb/modules/iOS_Emoji/service.log`
- Check post-mount log: `/data/adb/modules/iOS_Emoji/post-mount.log`
- Verify font is mounted: `mount | grep NotoColorEmoji`

### Magisk Specific Issues
- Ensure Magisk v24.0 or higher is installed
- Check that the module is enabled in Magisk app
- Try disabling other font-related modules

### Facebook/Messenger Issues
- Clear app data (not just cache) for Facebook apps
- Force stop the app and reopen
- The module attempts to replace Facebook's bundled emoji font

## File Structure

```
iOS_Emoji/
├── module.prop          # Module metadata
├── customize.sh         # Installation script
├── service.sh           # Boot service (late_start)
├── post-mount.sh        # Post-mount script (KernelSU)
├── boot-completed.sh    # Boot completed script (KernelSU)
├── action.sh            # Manual action script
├── uninstall.sh         # Cleanup on removal
├── system/
│   └── fonts/
│       └── NotoColorEmoji.ttf  # iOS 26.4 emoji font
├── META-INF/            # Magisk compatibility
├── update.json          # KernelSU update info
└── updater.json         # Magisk update info
```

## Contributing

Contributions are welcome! If you'd like to contribute, please:

1. Fork the repository
2. Create a new branch for your changes
3. Submit a pull request with a detailed description of your changes

Please ensure your code includes relevant documentation.

## Credits

- Original module by [solivexy](https://github.com/solivexy)
- iOS Emoji font source: [samuelngs/apple-emoji-linux](https://github.com/samuelngs/apple-emoji-linux)
- KernelSU: [tiann/KernelSU](https://github.com/tiann/KernelSU)
- Magisk: [topjohnwu/Magisk](https://github.com/topjohnwu/Magisk)
- APatch: [bmax121/APatch](https://github.com/bmax121/APatch)

## License

This project is licensed under the [MIT License](https://github.com/solivexy/KernelSU-iOS-Emoji/blob/main/LICENSE). Feel free to use, modify, and distribute it as per the license terms.
