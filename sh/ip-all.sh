#!/system/bin/sh

operate=$1
package_name=$2

IPTABLES=iptables
BUSYBOX=busybox
GREP=grep
ECHO=echo

# Try to find busybox
if /data/user/0/com.aidian.flowhelper/app_bin/busybox_g1 --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/data/user/0/com.aidian.flowhelper/app_bin/busybox_g1
        GREP="$BUSYBOX grep"
        ECHO="$BUSYBOX echo"
elif busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=busybox
elif /system/xbin/busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/system/xbin/busybox
elif /system/bin/busybox --help >/dev/null 2>/dev/null ; then
        BUSYBOX=/system/bin/busybox
fi

# Try to find grep
if ! $ECHO 1 | $GREP -q 1 >/dev/null 2>/dev/null ; then
        if $ECHO 1 | $BUSYBOX grep -q 1 >/dev/null 2>/dev/null ; then
                GREP="$BUSYBOX grep"
        fi
        # Grep is absolutely required
        if ! $ECHO 1 | $GREP -q 1 >/dev/null 2>/dev/null ; then
                $ECHO The grep command is required. DroidWall will not work.
                exit 1
        fi
fi

# Try to find iptables
if ! command -v iptables &> /dev/null; then
if /data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5 --version >/dev/null 2>/dev/null ; then
        IPTABLES=/data/user/0/com.aidian.flowhelper/app_bin/iptables_armv5
fi
fi

$IPTABLES --version || exit 1

# Flush existing rules
$IPTABLES -F || exit 2

# Create the droidwall chains if necessary
$IPTABLES -L droidwall >/dev/null 2>/dev/null || $IPTABLES --new droidwall || exit 3
$IPTABLES -L droidwall-reject >/dev/null 2>/dev/null || $IPTABLES --new droidwall-reject || exit 4

# Add droidwall chain to OUTPUT chain if necessary
$IPTABLES -L OUTPUT | $GREP -q droidwall || $IPTABLES -A OUTPUT -j droidwall || exit 5
$IPTABLES -L OUTPUT | $GREP -q droidwall-reject || $IPTABLES -A OUTPUT -j droidwall-reject || exit 6

# Reject all traffic for the specified UID (10100)
$IPTABLES -A droidwall -m owner --uid-owner 10100 -j REJECT || exit 7

# Reject both incoming and outgoing traffic for UID 10100
$IPTABLES -A INPUT -m owner --uid-owner 10100 -j REJECT || exit 8
$IPTABLES -A OUTPUT -m owner --uid-owner 10100 -j REJECT || exit 9

# If necessary, block DNS for the specific UID (UDP 53)
$IPTABLES -A OUTPUT -p udp --dport 53 -m owner --uid-owner 10100 -j DROP || exit 10

exit
