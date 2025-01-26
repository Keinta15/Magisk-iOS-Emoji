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

# Paths for cleanup
DATA_FONTS_DIR="/data/fonts"
GMS_FONTS_DIR="/data/data/com.google.android.gms/files/fonts/opentype"

# Ensure the log directory exists
mkdir -p "$MODPATH"

# Logging function with size and age management
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

    # Append the new log entry
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to check if a package/service exists
service_exists() {
    pm list packages | grep -q "$1"
    return $?
}

# Log script header
log "================================================"
log "iOS Emoji 17.4.7 service.sh Script"
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
    EMOJI_FONTS=$(find /data/data -iname "*emoji*.ttf" -print)

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

# Force-stop Facebook apps after all replacements are done
log "INFO: Force-stopping Facebook apps..."
for app in $FACEBOOK_APPS; do
    if ! am force-stop "$app"; then
        log "ERROR: Failed to force-stop app: $app"
    else
        log "INFO: Successfully force-stopped app: $app"
    fi
done

# Add a delay to allow the system to process the changes
sleep 2

# Disable GMS font services if they exist
if service_exists "$GMS_FONT_PROVIDER"; then
    log "INFO: Disabling GMS font provider: $GMS_FONT_PROVIDER"
    if ! pm disable "$GMS_FONT_PROVIDER"; then
        log "ERROR: Failed to disable GMS font provider: $GMS_FONT_PROVIDER"
    else
        log "INFO: Successfully disabled GMS font provider: $GMS_FONT_PROVIDER"
    fi
else
    log "INFO: GMS font provider not found: $GMS_FONT_PROVIDER"
fi

if service_exists "$GMS_FONT_UPDATER"; then
    log "INFO: Disabling GMS font updater: $GMS_FONT_UPDATER"
    if ! pm disable "$GMS_FONT_UPDATER"; then
        log "ERROR: Failed to disable GMS font updater: $GMS_FONT_UPDATER"
    else
        log "INFO: Successfully disabled GMS font updater: $GMS_FONT_UPDATER"
    fi
else
    log "INFO: GMS font updater not found: $GMS_FONT_UPDATER"
fi

# Clean up leftover font files
log "INFO: Cleaning up leftover font files..."
if [ -d "$DATA_FONTS_DIR" ]; then
    if ! rm -rf "$DATA_FONTS_DIR"; then
        log "ERROR: Failed to clean up directory: $DATA_FONTS_DIR"
    else
        log "INFO: Successfully cleaned up directory: $DATA_FONTS_DIR"
    fi
else
    log "INFO: Directory not found: $DATA_FONTS_DIR"
fi

# Commented out the deletion of .ttf files in the opentype directory
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