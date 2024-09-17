MODDIR=${0%/*}

# Check if /data/fonts exists and deletes it (removing the need to run the troubleshooting step, thanks @bugreportion)
[ -d /data/fonts ] && rm -rf /data/fonts


# Set paths relative to the module's directory
MODDIR="${0%/*}"
FONT_FILE="$MODDIR/system/fonts/NotoColorEmoji.ttf"
SYSTEM_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"
FACEBOOK_FONT_FILE="$MODDIR/system/fonts/NotoColorEmoji.ttf"

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
        ui_print "Successfully mounted $source to $target and set permissions"
    else
        ui_print "Failed to mount $source to $target"
    fi
}

# Mount system emoji font
if [ -f "$FONT_FILE" ]; then
    mount_font "$FONT_FILE" "$SYSTEM_FONT_FILE"
fi

# Mount Facebook emoji font if Facebook Messenger is installed
if package_installed "com.facebook.orca"; then
    ui_print "Facebook Messenger Installed Detected"
    ui_print "Mounting custom emoji font for Facebook Messenger"
    mount_font "$FACEBOOK_FONT_FILE" "/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf"
fi

# Mount Facebook emoji font if Facebook is installed
if package_installed "com.facebook.katana"; then
    ui_print "Facebook Installed Detected"
    ui_print "Mounting custom emoji font for Facebook"
    mount_font "$FACEBOOK_FONT_FILE" "/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf"
fi
