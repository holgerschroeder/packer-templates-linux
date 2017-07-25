#!/bin/bash -e

# after we have set the final sources, we
# need to run apt-get update to fetch the
# package descriptions. otherwise users
# will see a strange error if they want to
# install packages.

function fail() {
    echo error: $*
    exit 1
}

apt-get update || fail "apt-get update"

echo "success"
