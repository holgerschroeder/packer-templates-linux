#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# install kde
dnf -y group install kde-desktop-environment

echo "success"
