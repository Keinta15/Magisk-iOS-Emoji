# Magisk-iOS-Emoji
Systemlessly replaces emoji font with iOS Emoji 

> [!TIP]
> ~~I'll be working on streamlining the code and adding KernelSU support~~ soon. Life has been quite busy lately!
> Feel free to do a pull request 

## Changelog
v17.4.1
- Added Magisk 27005+ Support (on [b8339eb](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b8339eb2a38d0876d2c8d640329e517816ced6ce) thanks to [E85Addict](https://github.com/E85Addict))
- Added OverlayFS Support (on [b9e6e0f](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b9e6e0f374759c70dccd78c8791e4bb9d37b75a9) thanks to [reddxae](https://github.com/reddxae))
- Moved away from install.sh as recommended on [Magisk Docs](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md) and moved to customize.sh (added on [bc52d16](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/bc52d16186e6d53398f7b7c552c4251fd5e15a4b))

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
If Emoji files are replaced, reboot your phone.

## Tested on
- OnesPlus 11 (A14)
- OnesPlus 8T (A13)
- OnePlus 6
- [Reported working by users](https://github.com/Keinta15/Magisk-iOS-Emoji/issues?q=is%3Aissue+is%3Aclosed+label%3A%22reported+working%22)

## To-Do List
- ~~Add Magisk 27005+ Support~~ (added on [b8339eb](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b8339eb2a38d0876d2c8d640329e517816ced6ce) thanks to [E85Addict](https://github.com/E85Addict))
- ~~Fix compatibility issues with KernelSU~~ (check [references](https://kernelsu.org/guide/difference-with-magisk.html))
- ~~Add OverlayFS Support~~ (added on [b9e6e0f](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b9e6e0f374759c70dccd78c8791e4bb9d37b75a9) thanks to [reddxae](https://github.com/reddxae))
- ~~Moved away from install.sh based on [Magisk Docs](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md) and move to customize.sh~~ (added on [bc52d16](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/bc52d16186e6d53398f7b7c552c4251fd5e15a4b))
- ~~Update META-INF~~
- ~~Streamlined the code~~
- ~~Look into adding a service.sh or maybe an action.sh? to fix [Issue #31](https://github.com/Keinta15/Magisk-iOS-Emoji/issues/31)~~
- ~~Look into GMS Font providers~~
- ~~Look into the [Issue #18](https://github.com/Keinta15/Magisk-iOS-Emoji/issues/18) for Nothing phones~~ 
