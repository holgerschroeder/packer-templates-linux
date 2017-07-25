#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we set the timezone to Europe/Berlin

cat > /etc/timezone <<EOF || fail "setting timezone"
Europe/Berlin
EOF

echo "success"
