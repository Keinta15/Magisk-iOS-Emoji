# Magisk-iOS-Emoji
Systemlessly replaces emoji font with iOS Emoji 

> [!TIP]
> If you encounter issues installing and using on KernelSU, consider trying either this [module from dtingley11](https://github.com/dtingley11/KernelSU-iOS-Emoji) or this [module from bugreportion](https://github.com/bugreportion/Magisk-iOS-Emoji).

> I'll be working on streamlining the code and adding KernelSU support soon. Life has been quite busy lately!

## Changelog
v17.4
- Added 17.4 Emojis
- Added process to clear Gboard Cache

v16.4
- Added 16.4 Emojis
- Fixed Typo
<details><summary>Click to view prior changelogs</summary>

v15.4.6
- Added Android 12 Support
- Fixed typo on extraction 
- Added Android 13 Support

v15.4.5
- Removed method to replace Google Keyboard emoji as it was conflicting with other apps settings.

v15.4.4
- Forgot to add the xml file to the module
- Fixed typo

15.4.3
- Merged the normal module and the Samsung module into one
- Fixed a directory path that was wrong on the install file
- Added compatibility for other devices like LG and HTC

15.4.2 
- Added method to potentially completely replace Google Keyboard Emojis
- Testing updater.json directly from the Magisk Manager

15.4.1
- Added updater json for the ability to update directly from the Magisk Manager
- Cleaned code a bit

15.4
- Added 15.4 Emojis

14.6
- Added 14.6 Emojis
- Added method to replace Facebook and Facebook Messenger App's Emojis

14.2
- Added 14.2 Emojis
- Fixed a naming error on Samsung Devices
</details>

## Changelog for emojis
[17.4 new emojis](https://blog.emojipedia.org/ios-17-4-emoji-changelog/)

[16.4 new emojis](https://blog.emojipedia.org/ios-16-4-emoji-changelog/)

[15.4 new emojis](https://blog.emojipedia.org/ios-15-4-emoji-changelog/)

[14.6 new emojis](https://blog.emojipedia.org/ios-14-6-emoji-changelog/)

[14.2 new emojis](https://blog.emojipedia.org/ios-14-2-emoji-changelog/)

## Troubleshooting 
If it doesn't work delete all files under /data/font/files/(Random folder name)

## Tested on
- OnesPlus 11 (A14)
- OnesPlus 8T (A13)
- OnePlus 6
- [Reported working by users](https://github.com/Keinta15/Magisk-iOS-Emoji/issues?q=is%3Aissue+is%3Aclosed+label%3A%22reported+working%22)
