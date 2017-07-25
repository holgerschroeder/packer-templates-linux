#!/bin/bash -e

# here we put "nice things" for the shell.

# we add a ~/bin directory, and we add it to the PATH,
# so that it can be used by later scripts to put
# commands there

function fail() {
    echo error: $*
    exit 1
}

cat > /etc/skel/.bash_aliases <<EOF || fail "creating bash_aliases"
export PATH=\${PATH}:\${HOME}/bin
EOF

mkdir /etc/skel/bin || fail "mkdir skel bin"

echo "success"
