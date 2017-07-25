#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we install some base packages for our
# setup

# do nothing for fedora

echo "success"
