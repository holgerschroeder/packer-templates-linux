#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we set an apt proxy.

cat > /etc/apt/apt.conf.d/95proxies <<EOF || fail "setting apt proxy"
Acquire {
    http {
        proxy "http://10.0.0.1:3142";
    }
}
EOF

echo "success"
