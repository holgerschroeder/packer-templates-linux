#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# deactivate the default sources.list that was created in step1
mv /etc/apt/sources.list /etc/apt/sources.list-deactivated || fail "disable existing sources.list"

# create direct sources.list template
cat > /etc/apt/sources-direct.list.template <<EOF || fail "setting package repos"
# here we define the apt repositories that should be used
# by the virtual machine, so that it can install packages.

# (this is the default for a ubuntu install)

deb http://de.archive.ubuntu.com/ubuntu/ yakkety main restricted
deb http://de.archive.ubuntu.com/ubuntu/ yakkety-updates main restricted

deb http://de.archive.ubuntu.com/ubuntu/ yakkety universe
deb http://de.archive.ubuntu.com/ubuntu/ yakkety-updates universe

deb http://de.archive.ubuntu.com/ubuntu/ yakkety multiverse
deb http://de.archive.ubuntu.com/ubuntu/ yakkety-updates multiverse

deb http://de.archive.ubuntu.com/ubuntu/ yakkety-backports main restricted universe multiverse


deb http://security.ubuntu.com/ubuntu yakkety-security main restricted
deb http://security.ubuntu.com/ubuntu yakkety-security universe
deb http://security.ubuntu.com/ubuntu yakkety-security multiverse
EOF

# create company internal sources.list template
cat > /etc/apt/sources-mycompany.list.template <<EOF || fail "setting package repos"
# these are the company-internal repos

deb http://10.0.0.1/ubuntu yakkety main restricted universe multiverse
EOF

echo "success"
