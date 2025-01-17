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

# Definitions
FONT_DIR="$MODPATH/system/fonts"
FONT_EMOJI="NotoColorEmoji.ttf"
SYSTEM_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"
MSG_DIR="/data/data/com.facebook.orca"
FB_DIR="/data/data/com.facebook.katana"
FB_EMOJI_DIR="app_ras_blobs" 


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

# Replace system emoji fonts
ui_print "- Installing Emojis"
variants=(
    "SamsungColorEmoji.ttf"
    "LGNotoColorEmoji.ttf"
    "HTC_ColorEmoji.ttf"
    "AndroidEmoji-htc.ttf"
    "ColorUniEmoji.ttf"
    "DcmColorEmoji.ttf"
    "CombinedColorEmoji.ttf"
    "NotoColorEmojiLegacy.ttf"
)

for font in "${variants[@]}"; do
    if [ -f "/system/fonts/$font" ]; then
        if cp "$FONT_DIR/$FONT_EMOJI" "$FONT_DIR/$font"; then
            ui_print "- Replaced $font"
        else
            ui_print "- Failed to replace $font"
        fi
    fi
done
  
# Mount system emoji font
if [ -f "$FONT_DIR/$FONT_EMOJI" ]; then
    if mount_font "$FONT_DIR/$FONT_EMOJI" "$SYSTEM_FONT_FILE"; then
        ui_print "- System font mounted successfully"
    else
        ui_print "- Failed to mount system font"
    fi
fi

# Replace Facebook and Messenger emojis
replace_emojis "com.facebook.orca" "$MSG_DIR" "$FB_EMOJI_DIR"
replace_emojis "com.facebook.katana" "$FB_DIR" "$FB_EMOJI_DIR"
  
# Clear Gboard cache if installed
if package_installed "com.google.android.inputmethod.latin"; then
    ui_print "- Clearing Gboard Cache"
    clear_cache "com.google.android.inputmethod.latin"
fi
  
# Remove /data/fonts directory for Android 12+ instead of replacing the files (removing the need to run the troubleshooting step, thanks @reddxae)
if [ -d "/data/fonts" ]; then
    rm -rf "/data/fonts"
    ui_print "- Removed existing /data/fonts directory"
fi

# Handle fonts.xml symlinks
[[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
FONTS=/system/etc/fonts.xml
FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' "$MIRRORPATH$FONTS")
for font in $FONTFILES; do
    ln -s /system/fonts/NotoColorEmoji.ttf "$MODPATH/system/fonts/$font"
done

# Set permissions
ui_print "- Setting Permissions"
set_perm_recursive "$MODPATH" 0 0 0755 0644
ui_print "- Done"
ui_print "- Enjoy :)"

# OverlayFS Support based on https://github.com/HuskyDG/magic_overlayfs 
OVERLAY_IMAGE_EXTRA=0
OVERLAY_IMAGE_SHRINK=true

# Only use OverlayFS if Magisk_OverlayFS is installed
if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
    /data/adb/modules/magisk_overlayfs/overlayfs_system --test; then
  ui_print "- Add support for overlayfs"
  . /data/adb/modules/magisk_overlayfs/util_functions.sh
  support_overlayfs && rm -rf "$MODPATH"/system
fi
