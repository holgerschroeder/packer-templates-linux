#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we install kde and firefox

export DEBIAN_FRONTEND=noninteractive

apt-get -y install kde-plasma-desktop || fail "apt-get install kde-plasma-desktop"

apt-get -y install firefox-esr || fail "apt-get install firefox-esr"

echo "success"
