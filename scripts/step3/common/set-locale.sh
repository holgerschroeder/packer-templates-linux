#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we set the locale to en_US.utf8.
# we do this to:
# - see english error messages only
# - make e.g. yocto happy, because it needs
#   a utf8 locale

update-locale LANG=en_US.utf8 LANGUAGE=en_US.utf8 || fail "setting en_US.utf8 locale"

echo "success"
