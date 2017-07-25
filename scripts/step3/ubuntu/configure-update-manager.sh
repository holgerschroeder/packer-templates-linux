#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we tell the ubuntu update manager to
# never ask us if we want to update your
# ubuntu distribution to a newer release.

cat > /etc/update-manager/release-upgrades <<EOF || fail "setting release-upgrades config"
[DEFAULT]
Prompt=never
EOF

echo "success"
