
## Changelog
v18.4
- Added 18.4 Emojis ([Unicode 16.0](https://emojipedia.org/unicode-16.0)). Thanks to [samuelngs/apple-emoji-linux](https://github.com/samuelngs/apple-emoji-linux) for the source.
- Added action.sh for user convenience
- Updated log function to display messages properly when running the action

v17.4.7
- **Facebook Lite/Messenger Lite Support**  
  Added emoji replacement compatibility for:
  - Facebook Lite (`com.facebook.lite`)
  - Messenger Lite (`com.facebook.mlite`)
- **`display_name()` function**  
 Added function to display app names instead of package name `com.facebook.katana`

- **Case-Insensitive Font Detection**  
  Modified `replace_emoji_fonts()` in `service.sh` to use:  
  `find -iname "*emoji*.ttf"` instead of case-sensitive matching
- **Cache Clearing Lag**  
  Rewrote `clear_cache()` to eliminate delays caused by recursive `find` in `/data`  
  *New implementation uses direct path targeting for faster cleanup*

v17.4.6
- Updated `META-INF` (see [3e9dd3b](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/3e9dd3ba0d13f43f70bf299d4c727ffe3152c6b6)).  
- Restructured `customize.sh` code (see [16ef755](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/16ef7553211f7de5e5f1791f6609c92de4c6c7de)), making it easier to update.  
- Added `service.sh` (see [e7ae407](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/e7ae4077bf17e2b9e2c28b6aac75db1f7be11003)), eliminating the need for troubleshooting steps. Instead, simply restart your device.  

v17.4.1
- Added Magisk 27005+ Support (on [b8339eb](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b8339eb2a38d0876d2c8d640329e517816ced6ce) thanks to [E85Addict](https://github.com/E85Addict))
- Added OverlayFS Support (on [b9e6e0f](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/b9e6e0f374759c70dccd78c8791e4bb9d37b75a9) thanks to [reddxae](https://github.com/reddxae))
- Moved away from `install.sh` as recommended on [Magisk Docs](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md) and moved to `customize.sh` (added on [bc52d16](https://github.com/Keinta15/Magisk-iOS-Emoji/commit/bc52d16186e6d53398f7b7c552c4251fd5e15a4b))

v17.4
- Added 17.4 Emojis

v16.4
- Added 16.4 Emojis
- Fixed Typo

v15.4.6
- Added Android 12 Support
- Fixed typo on extraction
- Added Android 13 Support
