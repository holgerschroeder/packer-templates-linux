#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we install the vmware tools from the
# installed host vmware workstation itself.

# Mount the disk image
cd /tmp || fail cd
mkdir /tmp/isomount || fail mkdir
mount -t iso9660 -o loop /tmp/vmware-tools-linux.iso /tmp/isomount || fail mount

# Install the drivers
cp /tmp/isomount/VMwareTools-*.gz /tmp || fail cp
tar -zxvf VMwareTools*.gz || fail tar
./vmware-tools-distrib/vmware-install.pl -default -force-install || fail vmware-install.pl

# Cleanup
umount isomount || fail umount
rm -rf isomount /tmp/vmware-tools-linux.iso /tmp/VMwareTools*.gz /tmp/vmware-tools-distrib || fail rm

echo "success"
