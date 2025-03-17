#!/system/bin/sh

# 1. Remount /system as read-write
echo "Mounting /system as read-write..."
mount -o remount -o rw /
if [ $? -ne 0 ]; then
    echo "Error: Failed to remount /system as read-write."
    exit 1
fi

# 2. Check and modify /system/build.prop
BUILD_PROP="/system/build.prop"

echo "Checking and modifying $BUILD_PROP..."

# Modify or add persist.sys.usb.config
if grep -q "^persist.sys.usb.config=" $BUILD_PROP; then
    # If the property exists, replace it with the desired value
    sed -i "s/^persist.sys.usb.config=.*/persist.sys.usb.config=adb/" $BUILD_PROP
else
    # If the property does not exist, add it at the end
    echo "persist.sys.usb.config=adb" >> $BUILD_PROP
fi

# Modify or add sys.usb.config
if grep -q "^sys.usb.config=" $BUILD_PROP; then
    # If the property exists, replace it with the desired value
    sed -i "s/^sys.usb.config=.*/sys.usb.config=adb/" $BUILD_PROP
else
    # If the property does not exist, add it at the end
    echo "sys.usb.config=adb" >> $BUILD_PROP
fi

# Modify or add sys.usb.configfs
if grep -q "^sys.usb.configfs=" $BUILD_PROP; then
    # If the property exists, replace it with the desired value
    sed -i "s/^sys.usb.configfs=.*/sys.usb.configfs=1/" $BUILD_PROP
else
    # If the property does not exist, add it at the end
    echo "sys.usb.configfs=1" >> $BUILD_PROP
fi

# Modify or add sys.usb.configfs
if grep -q "^s9.adbd.auto_start=" /vendor/etc/container/container.conf; then
    # If the property exists, replace it with the desired value
    sed -i "s/^s9.adbd.auto_start=.*/s9.adbd.auto_start=1/" /vendor/etc/container/container.conf
else
    # If the property does not exist, add it at the end
    echo "s9.adbd.auto_start=1" >> /vendor/etc/container/container.conf
fi

# 3. Remount /system as read-only
echo "Mounting /system as read-only..."
mount -o remount -o ro /
if [ $? -ne 0 ]; then
    echo "Error: Failed to remount /system as read-only."
    exit 1
fi

echo "USB configuration modified successfully."
exit 0
