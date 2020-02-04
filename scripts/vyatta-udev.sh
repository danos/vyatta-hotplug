#!/bin/sh

# Get the last PCI slot number in the device path.
PCISLOT=$(echo "$DEVPATH" | awk -F/ '{for(i = NF; i ; i--) { if ($i~/:.*:.*\./) { print $i; break;}}}')

socket="/var/run/vplane.socket"
if [ -S $socket ];
then
    if [ "$ACTION" = "add" ]; then
	/lib/vplane/vplane-uio "$PCISLOT"
    fi
    /opt/vyatta/sbin/vyatta-hotplug.pl --act="$ACTION" --pcislot="$PCISLOT"
fi
