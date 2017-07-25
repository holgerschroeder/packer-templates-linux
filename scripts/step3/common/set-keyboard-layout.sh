#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we set the keyboard layout to german

cat > /etc/default/keyboard <<EOF || fail "setting keyboard layout"
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="de"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
EOF

echo "success"
