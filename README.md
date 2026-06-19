# FancyMoji (previously a fork of [Magisk-iOS-Emoji](https://github.com/Keinta15/Magisk-iOS-Emoji/))
Systemlessly replaces the OS's default font with choosen emoji.

[![Stars](https://img.shields.io/github/stars/newhertz/FancyMoji?label=Stars&color=blue)](https://github.com/newhertz/FancyMoji)
[![Release](https://img.shields.io/github/v/release/newhertz/FancyMoji?label=Release&logo=github)](https://github.com/newhertz/FancyMoji/releases/latest)
[![Download](https://img.shields.io/github/downloads/newhertz/FancyMoji/total?label=Downloads&logo=github)](https://github.com/newhertz/FancyMoji/releases/)

> [!TIP]
> Contributions are welcome! If you'd like to help improve this module, feel free to submit a pull request. Check out the [Contributing](#contributing) section for more details.


## Installation
1. Download the latest release from the [Releases page](https://github.com/newhertz/FancyMoji/releases/latest).
2. Open the Magisk app.
3. Go to **Modules** → **Install from storage** and select the downloaded ZIP file.
4. Reboot your device.
5. Enjoy your new emojis system-wide!

## Compatibility
- **Magisk Version**: Requires Magisk v24.0 or higher.
- **Android Version**: Tested on Android 10 and above. May work on older versions, but not guaranteed.
- **Devices**: Works on most devices, should work with most AOSP custom roms.

## Screenshot
<img src="https://github.com/newhertz/FancyMoji/blob/main/iOS_Emoji_Screenshot.jpg" alt="iOS Emojis on Android" width="400" />  
*An example of iOS emojis displayed on an Android keyboard.*

## Changelog
### v1.0 FancyMoji
- New emoji selector and ability to add custom emoji ttf files!
- Added OneUI 8.5 Emojis ([Unicode 17.0](https://emojipedia.org/unicode-17.0))
- Added AOSP/Noto Emojis ([Unicode 17.0](https://emojipedia.org/unicode-17.0))
Thanks to [mistu01/MFFMEmoji](https://github.com/mistu01/MFFMEmoji) for the [source](https://github.com/mistu01/MFFMEmoji/tree/mffmemoji-05052026-69d3924) for the emojis bundled on this release!
### v26.4
- Added 26.4 Emojis ([Unicode 17.0](https://emojipedia.org/unicode-17.0)). Thanks to [mistu01/MFFMEmoji](https://github.com/mistu01/MFFMEmoji) for the [source](https://github.com/mistu01/MFFMEmoji/tree/mffmemoji-05052026-69d3924).

## Changelog for Emojis
- v1.0 FancyMoji [iOS](https://blog.emojipedia.org/apple-ios-26-4-emoji-changelog/), [OneUI](https://blog.emojipedia.org/samsung-one-ui-8-5-emoji-changelog/), [AOSP](https://blog.emojipedia.org/google-debuts-emoji-17-0-support/)
- [v26.4 Magisk-iOS-Emoji New Emojis](https://blog.emojipedia.org/apple-ios-26-4-emoji-changelog/)

## FAQ
### Q: Why aren't the emojis changing after installation?
A: Ensure that the module is enabled in Magisk and reboot your device. If the issue persists, clear the cache of your keyboard app (e.g., Gboard).

### Q: Does this work with third-party keyboards?
A: Yes, the module replaces the system emoji font, so it should work with any keyboard that uses system emojis.

### Q: Can I use this alongside other Magisk modules?
A: Yes, but conflicts may arise if another module modifies the system emojis. Disable conflicting modules if issues occur.

## Troubleshooting
If the emoji files are replaced, reboot your phone.

## Contributing
Contributions are welcome! If you'd like to contribute, please:
1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request with a detailed description of your changes.

Please ensure your code includes relevant documentation.

## License
This project is licensed under the [MIT License](https://github.com/newhertz/FancyMoji/blob/main/LICENSE). Feel free to use, modify, and distribute it as per the license terms.
