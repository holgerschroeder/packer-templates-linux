#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we set an apt proxy.

cat > /etc/apt/apt.conf.d/95-proxy-direct <<EOF || fail "setting direct proxy"
Acquire {
    http {
# you can add your own apt proxy / apt cahce here to speed
# up installations.
#        proxy "http://192.168.178.11:3142"
    }
}
EOF

echo "success"
