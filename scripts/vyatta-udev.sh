#!/bin/sh

# Get the last PCI slot number in the device path.
PCISLOT=$(echo "$DEVPATH" | awk -F/ '{for(i = NF; i ; i--) { if ($i~/:.*:.*\./) { print $i; break;}}}')

socket="/var/run/vplane.socket"
if [ -S $socket ];
then
    if [ "$SUBSYSTEM" = "uio" ]; then
	# We are only called for uio device add for vmware vmxnet3 nic. This
	# is to workaround a problem where the device initially appears bound
	# to the uio pci module (eg. uio_pci_generic) rather than the vmxnet3
	# kernel driver. In this case rebind it to vmxnet3 which will cause
	# the event we expected in the first place, a net device add. We then
	# proceed as normal.
	if [ -e "/var/run/vyatta/hotplug/$PCISLOT" ]; then
	    rm "/var/run/vyatta/hotplug/$PCISLOT"
	else
	    echo "$PCISLOT" > "/sys/bus/pci/drivers/$1/unbind"
	    echo "$PCISLOT" > "/sys/bus/pci/drivers/vmxnet3/bind"
	fi
        exit 0
    fi

    if [ "$ACTION" = "add" ]; then
	/lib/vplane/vplane-uio "$PCISLOT"
	if [ "$1" = "VMXNET3" ]; then
	    mkdir -p /var/run/vyatta/hotplug
	    touch "/var/run/vyatta/hotplug/$PCISLOT"
        fi
    fi
    /opt/vyatta/sbin/vyatta-hotplug.pl --act="$ACTION" --pcislot="$PCISLOT"
fi
