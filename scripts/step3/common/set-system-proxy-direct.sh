#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we enable the "direct" proxy setting

cp /etc/environment.direct.template /etc/environment || fail "setting direct proxy in /etc/environment"

echo "success"
