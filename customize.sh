##########################################################################################
#
# Installer Script
#
##########################################################################################

# Define module properties
MODID=iOS_Emoji
AUTOMOUNT=true
SKIPMOUNT=false
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=false

# Definitions
# Define the directory where the emoji font file is located within the module
FONT_DIR="$MODPATH/system/fonts"

# Define the name of the emoji font file
FONT_EMOJI="NotoColorEmoji.ttf"

# Define the system font directory
SYSTEM_FONT_DIR="/system/fonts"

# Get the directory where the script is located
MODDIR="${0%/*}"

# Adding Magisk Canary 27007 support?
NVBASE=data/adb

# Path to the custom emoji font file
FONT_FILE="$MODDIR/system/fonts/NotoColorEmoji.ttf"

# Path to the system's emoji font file
SYSTEM_FONT_FILE="/system/fonts/NotoColorEmoji.ttf"

# List of variant emoji font files
VARIANT_FONTS=(
  "SamsungColorEmoji.ttf"
  "LGNotoColorEmoji.ttf"
  "HTC_ColorEmoji.ttf"
  "AndroidEmoji-htc.ttf"
  "ColorUniEmoji.ttf"
  "DcmColorEmoji.ttf"
  "CombinedColorEmoji.ttf"
  "NotoColorEmojiLegacy.ttf"
)

# Determine manufacturer
DEVICE_MANUFACTURER=$(getprop ro.product.manufacturer)

# Function to determine manufacturer
get_manufacturer() {
    if [ "$DEVICE_MANUFACTURER" = "samsung" ]; then
        echo "samsung"
    elif [ "$DEVICE_MANUFACTURER" = "LGE" ]; then
        echo "lg"
    elif [ "$DEVICE_MANUFACTURER" = "HTC" ]; then
        echo "htc"
    elif [ "$DEVICE_MANUFACTURER" = "Google" ]; then
        echo "google"
    else
        echo "unknown" # Default case if manufacturer is not recognized
    fi
}

# Function to print module name
print_modname() {
    ui_print "*******************************"
    ui_print "*       iOS Emoji 17.4        *"
    ui_print "*******************************"
}

# Function called during module installation
on_install() {

    # Extract module files
    ui_print "- Extracting module files"
    ui_print "- Installing Emojis"
    unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

    # Loop through each variant font, check if it exists on the system, and replace it with the custom emoji font file if found.
    for font in "${VARIANT_FONTS[@]}"; do
        if [ -f "/system/fonts/$font" ]; then
            cp "$FONT_DIR/$FONT_EMOJI" "$FONT_DIR/$font" && ui_print "- Replacing $font"
        fi
    done


    # Clear cache data of Gboard
    ui_print "- Clearing Gboard Cache"
    [ -d /data/data/com.google.android.inputmethod.latin ] &&
        find /data -type d -path '*inputmethod.latin*/*cache*' \
                           -exec rm -rf {} + &&
        am force-stop com.google.android.inputmethod.latin && ui_print "- Done"

    # Symbolic link creation for font files defined in /system/etc/fonts.xml
    [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
    FONTS_XML=/system/etc/fonts.xml
    FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS_XML)
    for font in $FONTFILES; do
        ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
    done
}

# Function to set permissions for files and directories
set_permissions() {
    set_perm_recursive $MODPATH 0 0 0755 0644
}


# Get manufacturer
MANUFACTURER=$(get_manufacturer)

# Perform font file operations based on the determined manufacturer
if [ "$MANUFACTURER" = "samsung" ]; then
    SAMSUNG_FONT_FILE="$MODDIR/system/fonts/SamsungColorEmoji.ttf"
    mount -o bind "$FONT_FILE" "$SAMSUNG_FONT_FILE"
    chmod 644 "$SAMSUNG_FONT_FILE"
fi

if [ "$MANUFACTURER" = "lg" ]; then
    LGE_FONT_FILE="$MODDIR/system/fonts/LGNotoColorEmoji.ttf"
    mount -o bind "$FONT_FILE" "$LGE_FONT_FILE"
    chmod 644 "$LGE_FONT_FILE"
fi

if [ "$MANUFACTURER" = "htc" ]; then
    HTC_FONT_FILE="$MODDIR/system/fonts/HTC_ColorEmoji.ttf"
    mount -o bind "$FONT_FILE" "$HTC_FONT_FILE"
    chmod 644 "$HTC_FONT_FILE"
fi

if [ "$MANUFACTURER" = "google" ]; then
    GOOGLE_FONT_FILE="$MODDIR/system/fonts/GoogleColorEmoji.ttf"
    mount -o bind "$FONT_FILE" "$GOOGLE_FONT_FILE"
    chmod 644 "$GOOGLE_FONT_FILE"
fi
# Mount overlay to replace system emoji font
mount -o bind "$FONT_FILE" "$SYSTEM_FONT_FILE"

# Ensure correct permissions for the replacement file
chmod 644 "$SYSTEM_FONT_FILE"

# Function to check if a package is installed
package_installed() {
    local package="$1"
    if pm list packages "$package" >/dev/null; then # Checking if the package is listed directly with pm list packages instead of using grep on the output
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

# Mount FacebookEmoji.ttf to specified directories if Messenger and/or Facebook are installed
if package_installed "com.facebook.orca"; then
    ui_print "- Mounting Messenger Emoji Font"
    mount -o bind "$FONT_FILE" "/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf"
    chmod 644 "/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf"
fi

if package_installed "com.facebook.katana"; then
    ui_print "- Mounting Facebook Emoji Font"
    mount -o bind "$FONT_FILE" "/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf"
    chmod 644 "/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf"
fi

## Check for possible in-app emojis on boot time and change them
#echo 'MODDIR=${0%/*}
## Wait until the system has completed booting
#until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1; done

## Wait until the sdcard is mounted
#until [ -d /sdcard ]; do sleep 1; done

## Delay for stability
#sleep 1

## Function to update emojis in data directories
#update_data_emojis() {
#    # Find all font files in data directories with "Emoji" in the name
#    EMOJI_FONTS=$(find /data/data -name "*.ttf" -print | grep -E "Emoji")
#    
#    # Loop through each font file
#    for i in $EMOJI_FONTS; do
#        # Copy the custom emoji font to the data directory
#        cp $MODDIR/system/fonts/NotoColorEmoji.ttf $i
#        
#        # Force-stop Facebook apps to reload emojis
#        am force-stop com.facebook.orca
#        am force-stop com.facebook.katana
#        
#        # Set permissions for the font file and associated directories
#        set_perm_recursive $i 0 0 0755 700
#        set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
#        set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs 0 0 0755 755
#    done
#}

## Call the function to update emojis in data directories
#update_data_emojis

## Disable Google FontsProvider
#pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider


## Remove unnecessary font files
#[ -d "/data/fonts" ] && rm -rf "/data/fonts"  # If directory exists, delete it
#rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf'  > $MODPATH/service.sh

## Verify Android version
#ANDROID_VER=$(getprop ro.build.version.sdk)  # Get the Android SDK version
## If Android 12+ detected
#if [ "$ANDROID_VER" -ge 31 ]; then  # Check if Android version is 12 or higher
#    ui_print "- Android 12+ Detected" 
#    [ -d "/data/fonts" ] && rm -rf "/data/fonts" && ui_print "- Deleting /data/fonts"  # If directory exists, delete it
#fi

# Adding OverlayFS Support
OVERLAY_IMAGE_EXTRA=0     # number of kb need to be added to overlay.img
OVERLAY_IMAGE_SHRINK=true # shrink overlay.img or not?

# Only use OverlayFS if Magisk_OverlayFS is installed
if [ -f "/data/adb/modules/magisk_overlayfs/util_functions.sh" ] && \
    /data/adb/modules/magisk_overlayfs/overlayfs_system --test; then
    ui_print "- Add support for overlayfs"
    . /data/adb/modules/magisk_overlayfs/util_functions.sh
    support_overlayfs && rm -rf "$MODPATH"/system
fi
