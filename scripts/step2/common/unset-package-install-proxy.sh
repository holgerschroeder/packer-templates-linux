#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we remove all apt proxy settings files

rm /etc/apt/apt.conf.d/95-proxy-* || fail "unsetting proxy"

echo "success"
