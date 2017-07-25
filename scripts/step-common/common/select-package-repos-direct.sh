#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we copy the sources.list template file
# from /etc/apt/ to /etc/apt/aources.list.d,
# this way we make it active.

SOURCESLIST=sources-direct.list

cp /etc/apt/${SOURCESLIST}.template \
/etc/apt/sources.list.d/${SOURCESLIST} || fail "enabling direct sources.list"

echo "success"
