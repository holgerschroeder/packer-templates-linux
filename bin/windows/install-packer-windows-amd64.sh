#!/bin/bash -e

function fail() {
    echo error: $*
    cd $MYPWD
    exit 1
}

if [ -z "${MYROOT}" ]; then
    echo "please load env-windows.sh in your shell window like this:"
    fail ". env-windows.sh";
fi

export MYOSTYPE=windows

install-packer.sh $* || fail "install packer failed"

echo "install packer success"
