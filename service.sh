MODDIR=${0%/*}

# Wait until the device has completed booting
until [ "$(getprop sys.boot_completed)" = 1 ]; do 
  sleep 1; 
done

# Wait until the /sdcard directory is available
until [ -d /sdcard ]; do 
  sleep 1
done

# Short pause to ensure readiness
sleep 1 

# Remove existing fonts directories
rm -rf /data/fonts

# Remove GMS font-related directories and files
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf

# Disable GMS font services
pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService

# Sleep for 6 hours before running again
sleep 21600 # 6 hours in seconds
