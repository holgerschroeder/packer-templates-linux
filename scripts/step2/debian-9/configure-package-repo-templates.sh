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

# (this is the default for a debian install)

deb http://deb.debian.org/debian stretch main contrib non-free
deb-src http://deb.debian.org/debian stretch main contrib non-free

deb http://deb.debian.org/debian stretch-updates main contrib non-free
deb-src http://deb.debian.org/debian stretch-updates main contrib non-free

deb http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free
EOF

# create company internal sources.list template
cat > /etc/apt/sources-mycompany.list.template <<EOF || fail "setting package repos"
# these are the company-internal repos

deb http://10.0.0.1/debian stretch main contrib non-free
EOF

echo "success"
