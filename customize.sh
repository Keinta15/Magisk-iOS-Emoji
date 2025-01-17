##########################################################################################
#
# Installer Script
#
##########################################################################################
#!/system/bin/sh

# Script Details
AUTOMOUNT=true
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

ui_print "*******************************"
ui_print "*       iOS Emoji 17.4        *"
ui_print "*******************************"

  #Definitions
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"

# Function to check if a package is installed
package_installed() {
    local package="$1"
    if pm list packages | grep -q "$package"; then
        return 0
    else
        return 1
    fi
}

mount_font() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$source" ]; then
        ui_print "- Source file $source does not exist"
        return 1
    fi
    
    mkdir -p "$(dirname "$target")"
    
    if mount -o bind "$source" "$target"; then
        chmod 644 "$target"
        ui_print "- Successfully mounted $source to $target and set permissions"
    else
        ui_print "- Failed to mount $source to $target"
        return 1
    fi
}

replace_emojis() {
    local app_name="$1"
    local app_dir="$2"
    local emoji_dir="$3"
    
    if package_installed "$app_name"; then
        ui_print "- $app_name Installed Detected"
        ui_print "- Mounting custom emoji font for $app_name"
        mount_font "$FONT_DIR/$FONT_EMOJI" "$app_dir/$emoji_dir/FacebookEmoji.ttf"
        am force-stop "$app_name" && ui_print "- Done"
    else
        ui_print "- $app_name not installed, skipping"
    fi
}

clear_cache() {
    local app_name="$1"
    if [ -d "/data/data/$app_name" ]; then
        find /data -type d -path "*$app_name*/*cache*" -exec rm -rf {} +
        am force-stop "$app_name"
        ui_print "- Cleared cache for $app_name"
    else
        ui_print "- $app_name cache not found, skipping"
    fi
}

  
# Extract module files
ui_print "- Extracting module files"
unzip -o "$ZIPFILE" 'system/*' -d "$MODPATH" >&2 || {
    ui_print "- Failed to extract module files"
    exit 1
}

  #Compatibility with different devices and potential Support for Android 13?
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NotoColorEmojiLegacy.ttf'
  for i in $variants ; do
    if [ -f "/system/fonts/$i" ]; then
        if cp "$FONT_DIR/$FONT_EMOJI" "$FONT_DIR/$i"; then
            ui_print "- Replaced $i"
        else
            ui_print "- Failed to replace $i"
        fi
    fi
  done
  
  #Facebook Messenger
  if [ -d "$MSG_DIR" ]; then
    ui_print "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
     $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Facebook App
  if [ -d "$FB_DIR" ]; then
    ui_print "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Verifying Android version
  android_ver=$(getprop ro.build.version.sdk)
  #if Android 12 detected
  if [ $android_ver -ge 31 ]; then
        DATA_FONT_DIR="/data/fonts/files"
    if [ -d "$DATA_FONT_DIR" ] && [ "$(ls -A $DATA_FONT_DIR)" ]; then
            ui_print "- Android 12+ Detected"
            ui_print "- Checking [$DATA_FONT_DIR]"
        for dir in $DATA_FONT_DIR/*/ ; do
                cd $dir
            for file in * ; do
                if [ "$file" == *ttf ] ; then
                    cp $FONT_DIR/$FONT_EMOJI $file && ui_print "- Replacing $file"
                fi
                done
        done
    fi
  fi
  #clear cache data of Gboard
    ui_print "- Clearing Gboard Cache"
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin
  
  [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
  FONTS=/system/etc/fonts.xml
  FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS)
  for font in $FONTFILES
  do
    ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
  done


  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
  set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700


#Adding OverlayFS Support based on https://github.com/HuskyDG/magic_overlayfs 
OVERLAY_IMAGE_EXTRA=0     # number of kb need to be added to overlay.img
OVERLAY_IMAGE_SHRINK=true # shrink overlay.img or not?

# Only use OverlayFS if Magisk_OverlayFS is installed
if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
    /data/adb/modules/magisk_overlayfs/overlayfs_system --test; then
  ui_print "- Add support for overlayfs"
  . /data/adb/modules/magisk_overlayfs/util_functions.sh
  support_overlayfs && rm -rf "$MODPATH"/system
fi
