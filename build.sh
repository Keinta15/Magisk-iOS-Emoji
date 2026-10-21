#!/bin/sh
# Build a flashable module zip from this directory.
# Usage: ./build.sh            -> dist/<id>-<version>.zip
set -eu

cd "$(dirname "$0")"

FONT="system/fonts/NotoColorEmoji.ttf"
FILES="META-INF module.prop customize.sh service.sh uninstall.sh action.sh system"

die() { echo "build.sh: $*" >&2; exit 1; }

for f in module.prop customize.sh service.sh uninstall.sh action.sh \
         META-INF/com/google/android/update-binary \
         META-INF/com/google/android/updater-script "$FONT"; do
    [ -e "$f" ] || die "missing required file: $f"
done

# A git-lfs pointer or empty file would produce a module with a broken font.
size=$(wc -c < "$FONT" | tr -d ' ')
[ "$size" -gt 1000000 ] || die "$FONT is only $size bytes (git-lfs pointer?)"

for s in customize.sh service.sh uninstall.sh action.sh; do
    sh -n "$s" || die "syntax error in $s"
done

id=$(sed -n 's/^id=//p' module.prop | tr -d '\r')
version=$(sed -n 's/^version=//p' module.prop | tr -d '\r')
[ -n "$id" ] && [ -n "$version" ] || die "id/version not found in module.prop"

chmod 755 customize.sh service.sh uninstall.sh action.sh

out="dist/${id}-${version}.zip"
mkdir -p dist
rm -f "$out"

if command -v zip >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    zip -qr -X -9 "$out" $FILES
elif command -v python3 >/dev/null 2>&1; then
    python3 - "$out" $FILES <<'PY'
import os, sys, zipfile
out, *paths = sys.argv[1:]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for p in paths:
        if os.path.isdir(p):
            for root, _, files in os.walk(p):
                for f in sorted(files):
                    z.write(os.path.join(root, f))
        else:
            z.write(p)
PY
else
    die "need either 'zip' or 'python3' installed"
fi

echo "Built $out ($(wc -c < "$out" | tr -d ' ') bytes)"
