#!/bin/bash -e

function fail() {
    echo error: $*
    cd $MYPWD
    exit 1
}

if [ -z "${MYROOT}" ]; then
    echo "please load env-linux.sh in your shell window like this:"
    fail ". env-linux.sh";
fi

export MYOSTYPE=linux

install-packer.sh $* || fail "install packer failed"

echo "install packer success"
