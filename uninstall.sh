#!/system/bin/sh
# Cleanup for iOS Emoji module. Runs when the module is removed (at next boot).

MODDIR=${0%/*}
LISTFILE="$MODDIR/installed.list"
OURFONT="$MODDIR/system/fonts/NotoColorEmoji.ttf"

CHATTR=""
if command -v chattr >/dev/null 2>&1; then
    CHATTR="chattr"
else
    for bb in /data/adb/ksu/bin/busybox /data/adb/ap/bin/busybox /data/adb/magisk/busybox; do
        if [ -x "$bb" ] && "$bb" --list 2>/dev/null | grep -qx chattr; then
            CHATTR="$bb chattr"
            break
        fi
    done
fi

remove_file() {
    [ -n "$CHATTR" ] && $CHATTR -i "$1" 2>/dev/null
    rm -f "$1"
}

# 1. Remove every file recorded by service.sh. This is exact and does not
#    depend on the font size.
if [ -f "$LISTFILE" ]; then
    while read -r f; do
        [ -n "$f" ] && [ -f "$f" ] && remove_file "$f"
    done < "$LISTFILE"
fi

# 2. Fallback for copies that were not recorded (e.g. made by an older version
#    of this module): match by the size of the font shipped in this module.
if [ -f "$OURFONT" ]; then
    FONT_SIZE=$(stat -c%s "$OURFONT" 2>/dev/null)
    if [ -n "$FONT_SIZE" ] && [ "$FONT_SIZE" -gt 1000000 ]; then
        for base in /data/data /data/user/0; do
            find "$base" -type f -size "${FONT_SIZE}c" 2>/dev/null | while read -r f; do
                remove_file "$f"
            done
        done
    fi
fi

# 3. Restore permissions of the Messenger font directories that were chmod 000
for d in /data/data/com.facebook.orca/files/fonts /data/user/0/com.facebook.orca/files/fonts; do
    [ -d "$d" ] && chmod 771 "$d"
done

# 4. Re-enable the GMS font services for all users
for u in $(ls /data/user 2>/dev/null); do
    pm enable --user "$u" "com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider" >/dev/null 2>&1
    pm enable --user "$u" "com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService" >/dev/null 2>&1
done

# 5. Restart the affected apps so they reload their fonts
for app in com.facebook.orca com.facebook.katana com.facebook.lite com.facebook.mlite; do
    am force-stop "$app" 2>/dev/null
done
