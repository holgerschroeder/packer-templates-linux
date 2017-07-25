#!/bin/bash -e

function fail() {
    echo error: $*
    exit 1
}

# here we copy and patch the /etc/environment file
# to add different possible proxy settings for
# "direct" internet access, and for "mycompany"-proxied
# internet access

cp /etc/environment /etc/environment.orig || fail "backing up original /etc/environment"

cp /etc/environment /etc/environment.mycompany.template || fail "copying /etc/environment"
cp /etc/environment /etc/environment.direct.template || fail "copying /etc/environment"

PROXY=http://10.0.0.1:10415

cat >> /etc/environment.mycompany.template <<EOF || fail "setting mycompany proxy in template"
# proxy settings for mycompany internal network

export http_proxy=${PROXY}
export https_proxy=${PROXY}
export ftp_proxy=${PROXY}

# make sure we can access the internal mycompany urls
# without going through the proxy
export no_proxy=localhost,.mycompany.com
EOF

# no special settings for non-mycompany proxy for now
cat >> /etc/environment.direct.template <<EOF || fail "setting direct proxy in template"
EOF

echo "success"
