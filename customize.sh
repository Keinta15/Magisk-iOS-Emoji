AUTOMOUNT=true
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

  ui_print "*******************************"
  ui_print "*       iOS Emoji 17.4        *"
  ui_print "*******************************"

  # Definitions
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  SYSTEM_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"
  
  # Creating functions:
  # Function to check if a package is installed
  package_installed() {
      local package="$1"
      if pm list packages | grep -q "$package"; then
          return 0
      else
          return 1
      fi
  }
  
  # Function to mount a font file and set permissions
  mount_font() {
      local source="$1"
      local target="$2"
      
      # Ensure the target directory exists
      mkdir -p "$(dirname "$target")"
      
      # Attempt to mount and set permissions
      if mount -o bind "$source" "$target"; then
          chmod 644 "$target"
          ui_print "- Successfully mounted $source to $target and set permissions"
      else
          ui_print "- Failed to mount $source to $target"
      fi
  }

  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  # Compatibility with different devices and potential Support for Android 13+ with NotoColorEmojiLegacy
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$FONT_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  # Mount system emoji font
  if [ -f "$FONT_DIR/$FONT_EMOJI" ]; then
      mount_font "$FONT_DIR/$FONT_EMOJI" "$SYSTEM_FONT_FILE"
  fi
  
  # Mount Facebook emoji font if Facebook Messenger is installed
  if package_installed "com.facebook.orca"; then
      ui_print "- Facebook Messenger Installed Detected"
      ui_print "- Mounting custom emoji font for Facebook Messenger"
      mount_font "$FONT_DIR/$FONT_EMOJI" "/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf"
      am force-stop com.facebook.orca && ui_print "- Done"
  fi
  
  # Mount Facebook emoji font if Facebook is installed
  if package_installed "com.facebook.katana"; then
      ui_print "- Facebook Installed Detected"
      ui_print "- Mounting custom emoji font for Facebook"
      mount_font "$FONT_DIR/$FONT_EMOJI" "/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf"
      am force-stop com.facebook.katana && ui_print "- Done"
  fi

#  if package_installed "com.google.android.gms"; then
#      ui_print "- GBoard Installed Detected"
#      ui_print "- Mounting custom emoji font for GBoard"
#      mount_font "$FONT_DIR/$FONT_EMOJI" "/data/data/com.google.android.gms/files/fonts/opentype/Noto_Color_Emoji_Compat.ttf"
#      am force-stop com.google.android.gms && ui_print "- Done"
#  fi 

  # Check if /data/fonts exists and deletes it (removing the need to run the troubleshooting step, thanks @bugreportion), basically anything Android 12+
  if [ -d /data/fonts ]; then
      rm -rf /data/fonts
      ui_print "- Removing existing /data/fonts directory"
  fi

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
  
  ui_print "- Setting Permissions"
  set_perm_recursive $MODPATH 0 0 0755 0644
  ui_print "- Done"
  ui_print "- Enjoy :)"

  # Adding OverlayFS Support based on https://github.com/HuskyDG/magic_overlayfs 
  OVERLAY_IMAGE_EXTRA=0     # number of kb need to be added to overlay.img
  OVERLAY_IMAGE_SHRINK=true # shrink overlay.img or not?
  
  # Only use OverlayFS if Magisk_OverlayFS is installed
  if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
      /data/adb/modules/magisk_overlayfs/overlayfs_system --test; then
    ui_print "- Adding support for overlayfs"
    . /data/adb/modules/magisk_overlayfs/util_functions.sh
    support_overlayfs && rm -rf "$MODPATH"/system
  fi

