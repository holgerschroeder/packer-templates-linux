#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we install xfce on top of ubuntu, so
# we basically install xubuntu

apt-get -y install ubuntu-standard || fail "apt-get install ubuntu-standard"
apt-get -y install xubuntu-desktop || fail "apt-get install xubuntu-desktop"

# remove these, so we are more similar to the xubuntu vanilla from before
# also xscreensaver is annoying in a vm...
apt-get -y remove xscreensaver || fail "remove xscreensaver"
apt-get -y remove signond || fail "remove signond"
apt-get -y autoremove || fail "autoremove"

# install language support for english, german and swedish
apt-get -y install `check-language-support -l en` || fail "english language support"
apt-get -y install `check-language-support -l de` || fail "german language support"
apt-get -y install `check-language-support -l sv` || fail "swedish language support"

echo "success"
