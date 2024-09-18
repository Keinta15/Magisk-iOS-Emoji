MODDIR=${0%/*}

until [ "$(getprop sys.boot_completed)" = 1 ]; do 
  sleep 1; 
done

until [ -d /sdcard ]; do sleep 1; done
sleep 1 

rm -rf /data/fonts
rm -rf /data/data/com.google.android.gms/files/fonts/opentype/*ttf
# pm disable com.google.android.gms/com.google.android.gms.fonts.provider.FontsProvider
# pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService

# Sleep for 6 hours before running again
sleep 21600 # 6 hours in seconds
