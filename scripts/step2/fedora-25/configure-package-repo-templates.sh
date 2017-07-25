#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# in this script we put the available package repos into
# files on the target system. the repos are not "enabled"
# by this script, because we want to offer both a "direct"
# installation from internet sources, and a "no-internet-access"
# installation from some company-internal repo servers.

echo doing nothing for now...
