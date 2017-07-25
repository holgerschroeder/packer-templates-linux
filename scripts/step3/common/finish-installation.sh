#!/bin/bash -e

# here we try to use dd to write zeros to disk,
# this way we try to shrink the vmware disk
# size in the vagrant box...

function fail() {
    echo error: $*
    exit 1
}

rm -r /var/cache/apt/archives/* || fail "rm apt archives"

# this will fail when the disk is full,
# do not throw error in this case
time dd if=/dev/zero of=/zeros oflag=direct bs=1M || true

sync || fail "sync"

rm /zeros || fail "could not remove zeros file"

echo "success"
