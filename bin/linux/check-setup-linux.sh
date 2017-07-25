#!/bin/bash -e

# here we check if all needed programs exist etc.

function fail() {
    echo error: $*
    exit 1
}

if [ -z "${MYROOT}" ]; then
    echo "please load env-linux.sh in your shell window like this:"
    fail ". env-linux.sh";
fi

# check if needed programs are installed
which vagrant >/dev/null || fail "please install vagrant"

vagrant plugin list | grep vagrant-vmware-workstation >/dev/null \
    || fail "please install vagrant-vmware-workstation"

which vmware >/dev/null || fail "please install vmware workstation"
which python >/dev/null || fail "please install python"
which wget >/dev/null || fail "please install wget"
which curl >/dev/null || fail "please install curl"

which sha256sum >/dev/null || fail "please install sha256sum"
which unzip >/dev/null || fail "please install unzip"

if ! which packer >/dev/null; then
    fail "please install packer with \"install-packer-linux-amd64.sh\""
fi

echo "check-setup-linux success"
