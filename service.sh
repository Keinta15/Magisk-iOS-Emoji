#!/system/bin/sh

# Module directory (where the script is located)
MODDIR=${0%/*}

# Logging configuration
LOGDIR="$MODDIR/logs"
LOGFILE="$LOGDIR/emoji_replace_service.log"
MAX_LOG_SIZE=$((5 * 1024 * 1024)) # 5 MB
MAX_LOG_FILES=3 # Keep up to 3 archived logs
MAX_LOG_AGE_DAYS=7 # Delete logs older than 7 days

# Facebook app package names
FACEBOOK_APPS="com.facebook.orca com.facebook.katana"

# GMS font services
GMS_FONT_PROVIDER="com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider"
GMS_FONT_UPDATER="com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"

# Ensure the log directory exists
mkdir -p "$LOGDIR"

# Logging function with size and age management
log() {
    # Delete old log files
    find "$LOGDIR" -name "$(basename "$LOGFILE")*" -type f -mtime +$MAX_LOG_AGE_DAYS -exec rm -f {} \;

    # Check if log file exists and is too large
    if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -gt $MAX_LOG_SIZE ]; then
        # Rotate logs
        for i in $(seq $MAX_LOG_FILES -1 1); do
            if [ -f "$LOGFILE.$i" ]; then
                mv "$LOGFILE.$i" "$LOGFILE.$((i+1))"
            fi
        done
        mv "$LOGFILE" "$LOGFILE.1"
        log "Log file rotated."
    fi

    # Append the new log entry
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to check if a package/service exists
service_exists() {
    pm list packages | grep -q "$1"
    return $?
}

# Wait until the device has completed booting
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5
done

# Wait until the /sdcard directory is available
while [ ! -d /sdcard ]; do
    sleep 5
done

log "Service started."

# Replace in-app emoji fonts
replace_emoji_fonts() {
    log "Starting emoji replacement process..."
    
    # Check if the source emoji font exists
    if [ ! -f "$MODDIR/system/fonts/NotoColorEmoji.ttf" ]; then
        log "Source emoji font not found. Skipping replacement."
        return
    fi

    # Find all .ttf files containing "Emoji" in their names
    EMOJI_FONTS=$(find /data/data -name "*Emoji*.ttf" -print)
    
    if [ -z "$EMOJI_FONTS" ]; then
        log "No emoji fonts found to replace. Skipping."
        return
    fi

    # Replace each emoji font with the custom font
    for font in $EMOJI_FONTS; do
        log "Replacing emoji font: $font"
        cp "$MODDIR/system/fonts/NotoColorEmoji.ttf" "$font"
        
        # Set permissions for the replaced file
        chmod 755 "$font"
        chown 0:0 "$font"
    done

    # Force-stop Facebook apps after all replacements are done
    log "Force-stopping Facebook apps..."
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
if service_exists "$GMS_FONT_PROVIDER"; then
    log "Disabling GMS font provider: $GMS_FONT_PROVIDER"
    pm disable "$GMS_FONT_PROVIDER"
else
    log "GMS font provider not found: $GMS_FONT_PROVIDER"
fi

if service_exists "$GMS_FONT_UPDATER"; then
    log "Disabling GMS font updater: $GMS_FONT_UPDATER"
    pm disable "$GMS_FONT_UPDATER"
else
    log "GMS font updater not found: $GMS_FONT_UPDATER"
fi

# Clean up leftover font files
log "Cleaning up leftover font files..."
rm -rf /data/fonts
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf

log "Service completed."
