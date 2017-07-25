#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we enable the "mycompany" proxy setting

cp /etc/environment.mycompany.template /etc/environment || fail "setting mycompany proxy in /etc/environment"

echo "success"
