AUTOMOUNT=true
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=true
LATESTARTSERVICE=false

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

REPLACE="
"

MODDIR="${0%/*}"

print_modname() {
  ui_print "*******************************"
  ui_print "*       iOS Emoji 17.4        *"
  ui_print "*******************************"
}

on_install() {
  # Definitions
  FONT_DIR=$MODDIR/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  # Compatibility with different devices and potential Support for Android 13?
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$FONT_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  # Clear cache data of Gboard
    ui_print "- Clearing Gboard Cache"
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin && echo "- Done"
  
  [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
  FONTS=/system/etc/fonts.xml
  FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS)
  for font in $FONTFILES
  do
    ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
  done
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
}

# Adding OverlayFS Support based on https://github.com/HuskyDG/magic_overlayfs 
OVERLAY_IMAGE_EXTRA=0     # number of kb need to be added to overlay.img
OVERLAY_IMAGE_SHRINK=true # shrink overlay.img or not?

# Only use OverlayFS if Magisk_OverlayFS is installed
if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
    /data/adb/modules/magisk_overlayfs/overlayfs_system --test; then
  ui_print "- Add support for overlayfs"
  . /data/adb/modules/magisk_overlayfs/util_functions.sh
  support_overlayfs && rm -rf "$MODPATH"/system
fi
