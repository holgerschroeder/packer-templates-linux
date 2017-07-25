#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# install some packages that make the life easier
dnf -y install git subversion curl emacs mc tmux socat || fail "convenience programs"

echo "success"
