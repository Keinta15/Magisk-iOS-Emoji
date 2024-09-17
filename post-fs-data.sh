MODDIR=${0%/*}

# Check if /data/fonts exists and deletes it (removing the need to run the troubleshooting step, thanks @bugreportion)
[ -d /data/fonts ] && rm -rf /data/fonts
