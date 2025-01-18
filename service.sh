#!/system/bin/sh

# Module directory (where the script is located)
MODPATH=${0%/*}

# Facebook app package names
FACEBOOK_APPS="com.facebook.orca com.facebook.katana"

# GMS font services
GMS_FONT_PROVIDER="com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider"
GMS_FONT_UPDATER="com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"

# Wait until the device has completed booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done

# Wait until the /sdcard directory is available
while [ ! -d /sdcard ]; do
    sleep 5
done

# Replace in-app emoji fonts
replace_emoji_fonts() {
    # Check if the source emoji font exists
    if [ ! -f "$MODPATH/system/fonts/NotoColorEmoji.ttf" ]; then
        return
    fi

    # Find all .ttf files containing "Emoji" in their names
    EMOJI_FONTS=$(find /data/data -name "*Emoji*.ttf" -print)
    
    if [ -z "$EMOJI_FONTS" ]; then
        return
    fi

    # Replace each emoji font with the custom font
    for font in $EMOJI_FONTS; do
        cp "$MODPATH/system/fonts/NotoColorEmoji.ttf" "$font"
        
        # Set permissions for the replaced file
        chmod 755 "$font"
        chown 0:0 "$font"
    done

    # Force-stop Facebook apps after all replacements are done
    for app in $FACEBOOK_APPS; do
        am force-stop "$app"
    done

    # Set permissions for Facebook app directories
    for app in $FACEBOOK_APPS; do
        set_perm_recursive "/data/data/$app/app_ras_blobs" 0 0 0755 755
    done
}

replace_emoji_fonts

# Disable GMS font services if they exist
if pm list packages | grep -q "$GMS_FONT_PROVIDER"; then
    pm disable "$GMS_FONT_PROVIDER"
fi

if pm list packages | grep -q "$GMS_FONT_UPDATER"; then
    pm disable "$GMS_FONT_UPDATER"
fi

# Clean up leftover font files
rm -rf /data/fonts
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf
