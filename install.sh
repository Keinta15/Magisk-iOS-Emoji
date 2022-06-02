##########################################################################################
#
# Installer Script
#
##########################################################################################

SKIPMOUNT=false

PROPFILE=false

POSTFSDATA=false

LATESTARTSERVICE=false

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

REPLACE="
"

print_modname() {
  ui_print "*******************************"
  ui_print "        iOS Emoji 15.4.3        "
  ui_print "*******************************"
}

on_install() {
  #Definitions
  TTF_EMOJI="NotoColorEmoji.ttf"
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  GK_XML="flag_value.xml"
  GK_DIR="/data/data/com.google.android.inputmethod.latin"
  XML_DIR="Shared_Prefs"
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  #Compatibility with different devices 
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$DEF_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  #Facebook Messenger
  if [ -d "$MSG_DIR" ]; then
    ui_print "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$TTF_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Facebook App
  if [ -d "$FB_DIR" ]; then
    ui_print "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$TTF_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Google Keyboard
  if [ -d "$GK_DIR" ]; then
    ui_print "- Replacing Google Keyboard Emojis"
    cd $GK_DIR
    rm -rf $XML_DIR
    mkdir $XML_DIR
    cd $XML_DIR
    cp $MODPATH/system/data/data/com.google.android.inputmethod.latin/$GK_XML ./Flags_Value.xml
  fi
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
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
  set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive /data/data/com.google.android.inputmethod.latin/Shared_Prefs/Flags_Value.xml 0 0 0755 660
}
