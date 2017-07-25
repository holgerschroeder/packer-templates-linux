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

# vmware tools need an installed ifconfig program.
# by default debian 9 does not contain that any more.
# so we need to install it by hand.
apt-get -y install net-tools || fail "apt-get install net-tools"

echo "success"
