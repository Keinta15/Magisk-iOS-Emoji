#!/system/bin/sh

# Module directory (where the script is located)
MODPATH=${0%/*}

# Logging configuration
LOGFILE="$MODPATH/service.log" # Log file
MAX_LOG_SIZE=$((5 * 1024 * 1024)) # 5 MB
MAX_LOG_FILES=3 # Keep up to 3 archived logs
MAX_LOG_AGE_DAYS=7 # Delete logs older than 7 days

# Facebook app package names
FACEBOOK_APPS="com.facebook.orca com.facebook.katana com.facebook.lite com.facebook.mlite"

# GMS font services
GMS_FONT_PROVIDER="com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider"
GMS_FONT_UPDATER="com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"
GMS_FONT_DIR_PATTERN="com.google.android.gms/files/fonts"

# Paths for cleanup
DATA_FONTS_DIR="/data/fonts"
GMS_FONTS_DIR="/data/data/com.google.android.gms/files/fonts/opentype"
GMS_FONT_DIR_PATTERN="com.google.android.gms/files/fonts"

# Messenger font directories
ORCA_FONT_DIR1="/data/data/com.facebook.orca/files/fonts"
ORCA_FONT_DIR2="/data/user/0/com.facebook.orca/files/fonts"

# Ensure the log directory exists
mkdir -p "$MODPATH"

# Logging function with user feedback
log() {
    # Delete old log files
    find "$MODPATH" -name "$(basename "$LOGFILE")*" -type f -mtime +$MAX_LOG_AGE_DAYS -exec rm -f {} \;

    # Check if log file exists and is too large
    if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -gt $MAX_LOG_SIZE ]; then
        # Rotate logs
        for i in $(seq $MAX_LOG_FILES -1 1); do
            if [ -f "$LOGFILE.$i" ]; then
                mv "$LOGFILE.$i" "$LOGFILE.$((i+1))"
            fi
        done
        mv "$LOGFILE" "$LOGFILE.1"
    fi

    # Create log message
    local log_message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$log_message" >> "$LOGFILE"
    
    # Display simplified message to user
    echo "[*] $(echo "$1" | sed 's/^[A-Z]*: //')"
}

# Function to check if a package/service exists
service_exists() {
    pm list packages | grep -q "$1"
    return $?
}

# Log script header
log "================================================"
log "iOS Emoji 18.4 service.sh Script"
log "Brand: $(getprop ro.product.brand)"
log "Device: $(getprop ro.product.model)"
log "Android Version: $(getprop ro.build.version.release)"
log "================================================"

# Wait until the device has completed booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done

# Wait until the /sdcard directory is available
while [ ! -d /sdcard ]; do
    sleep 5
done

log "INFO: Service started."

# Replace in-app emoji fonts
replace_emoji_fonts() {
    log "INFO: Starting emoji replacement process..."

    # Check if the source emoji font exists
    if [ ! -f "$MODPATH/system/fonts/NotoColorEmoji.ttf" ]; then
        log "ERROR: Source emoji font not found. Skipping replacement."
        return
    fi

    # Find all .ttf files containing "Emoji" in their names
    EMOJI_FONTS=$(find /data/data /data/user/0 -iname "*emoji*.ttf" 2>/dev/null)

    if [ -z "$EMOJI_FONTS" ]; then
        log "INFO: No emoji fonts found to replace. Skipping."
        return
    fi

    # Replace each emoji font with the custom font
    for font in $EMOJI_FONTS; do
        # Check if the target font file is writable
        if [ ! -w "$font" ]; then
            log "ERROR: Font file is not writable: $font"
            continue
        fi

        log "INFO: Replacing emoji font: $font"
        if ! cp "$MODPATH/system/fonts/NotoColorEmoji.ttf" "$font"; then
            log "ERROR: Failed to replace emoji font: $font"
        else
            log "INFO: Successfully replaced emoji font: $font"
        fi

        # Set permissions for the replaced file
        if ! chmod 644 "$font"; then
            log "ERROR: Failed to set permissions for: $font"
        else
            log "INFO: Successfully set permissions for: $font"
        fi
    done

    log "INFO: Emoji replacement process completed."
}

replace_emoji_fonts

lock_messenger_emoji() {
    log "INFO: Applying permanent Messenger/Facebook emoji lock..."

    for pkg in $FACEBOOK_APPS; do
        if [ ! -d "/data/data/$pkg" ]; then
            log "INFO: Package not found, skipping lock: $pkg"
            continue
        fi

        target="/data/data/$pkg/app_ras_blobs/FacebookEmoji.ttf"
        mkdir -p "/data/data/$pkg/app_ras_blobs"

        log "INFO: Locking emoji file for $pkg"

        if ! cp -f "$MODPATH/system/fonts/NotoColorEmoji.ttf" "$target"; then
            log "ERROR: Failed to copy font to $target"
            continue
        fi

        if ! chmod 444 "$target"; then
            log "ERROR: Failed to set read-only permissions on $target"
        else
            log "INFO: Successfully set read-only permissions on $target"
        fi

        # Try to make the file truly immutable
        if chattr +i "$target" 2>/dev/null; then
            log "INFO: Successfully made file immutable (chattr +i): $target"
        else
            log "INFO: chattr +i not supported or failed (normal on some filesystems) - using read-only fallback"
        fi
    done

    log "INFO: Permanent Messenger/Facebook emoji lock completed."
}

lock_messenger_emoji

# Clean Messenger emoji caches
log "INFO: Cleaning Messenger font caches..."

for dir in "$ORCA_FONT_DIR1" "$ORCA_FONT_DIR2"; do
    if [ -d "$dir" ]; then
        if rm -rf "$dir"/*; then
            log "INFO: Successfully cleaned Messenger font cache: $dir"
        else
            log "ERROR: Failed to clean Messenger font cache: $dir"
        fi
    else
        log "INFO: Messenger font cache directory not found: $dir"
    fi
done

# Block Messenger from downloading emoji fonts
log "INFO: Blocking Messenger emoji font downloads..."

for dir in "$ORCA_FONT_DIR1" "$ORCA_FONT_DIR2"; do
    if mkdir -p "$dir"; then
        log "INFO: Created directory: $dir"
    else
        log "ERROR: Failed to create directory: $dir"
    fi

    if chmod 000 "$dir"; then
        log "INFO: Locked directory permissions: $dir"
    else
        log "ERROR: Failed to lock directory: $dir"
    fi
done

# Force-stop Facebook apps after all replacements are done
log "INFO: Force-stopping apps..."
for app in $FACEBOOK_APPS; do
    if ! am force-stop "$app"; then
        log "ERROR: Failed to force-stop app: $app"
    else
        log "INFO: Successfully force-stopped app: $app"
    fi
done

# Add a delay to allow the system to process the changes
sleep 2

# Disable GMS font services for all users
disable_gms_font_services() {
    log "INFO: Disabling GMS font services for all users..."

    USERS=$(ls -d /data/user/* 2>/dev/null)

    for userpath in $USERS; do

        USERID=${userpath##*/}

        if pm disable --user "$USERID" "$GMS_FONT_PROVIDER" >/dev/null 2>&1; then
            log "INFO: Disabled GMS font provider for user $USERID"
        fi

        if pm disable --user "$USERID" "$GMS_FONT_UPDATER" >/dev/null 2>&1; then
            log "INFO: Disabled GMS font updater for user $USERID"
        fi

    done
}

disable_gms_font_services

# Remove GMS generated fonts
cleanup_gms_fonts() {
log "INFO: Cleaning up leftover font files..."

    if [ -d "$DATA_FONTS_DIR" ]; then
        rm -rf "$DATA_FONTS_DIR"
        log "INFO: Removed $DATA_FONTS_DIR"
    fi

    find /data -type d -path "*$GMS_FONT_DIR_PATTERN*" 2>/dev/null | while read dir; do
        if rm -rf "$dir"; then
            log "INFO: Removed GMS font directory: $dir"
        else
            log "ERROR: Failed removing: $dir"
        fi
    done
}

cleanup_gms_fonts

# Commented out the deletion of .ttf files in the opentype directory (still need testing)
# if [ -d "$GMS_FONTS_DIR" ]; then
#     if ! rm -rf "$GMS_FONTS_DIR"/*ttf; then
#         log "ERROR: Failed to clean up ttf files in directory: $GMS_FONTS_DIR"
#     else
#         log "INFO: Successfully cleaned up ttf files in directory: $GMS_FONTS_DIR"
#     fi
# else
#     log "INFO: Directory not found: $GMS_FONTS_DIR"
# fi

log "INFO: Service completed."
log "================================================"