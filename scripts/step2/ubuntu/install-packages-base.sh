#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we install some base packages for our
# setup

export DEBIAN_FRONTEND=noninteractive

apt-get -y update || fail "apt-get update"
apt-get -y dist-upgrade || fail "apt-get dist-upgrade"
# perhaps remove old unused kernel(s)
apt-get -y autoremove || fail "autoremove"

echo "success"
