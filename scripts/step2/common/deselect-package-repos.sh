#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we remove all set debian package repos.
# we only copied the files to these locations,
# so we still have the original files in the
# parent directory /etc/apt/

rm /etc/apt/sources.list.d/*.list || fail "unsetting own sources"

echo "success"
