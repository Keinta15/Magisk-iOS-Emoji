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
  ui_print "        iOS Emoji 15.4         "
  ui_print "*******************************"
}

on_install() {
  CUR_EMOJI="NotoColorEmoji.ttf"
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  ui_print "- Extracting module files"
  ui_print "- Installing Emojis"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
  if [ -d "$MSG_DIR" ]; then
    echo "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$CUR_EMOJI ./FacebookEmoji.ttf
  fi
  if [ -d "$FB_DIR" ]; then
    echo "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$CUR_EMOJI ./FacebookEmoji.ttf
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
}
