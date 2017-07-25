# here we just add the scripts etc. to the PATH

export MYROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo MYROOT: ${MYROOT}

export PATH=${PATH}:${MYROOT}/bin
export PATH=${PATH}:${MYROOT}/bin/linux
export PATH=${PATH}:${MYROOT}/3rdparty/packer_1.0.0_linux_amd64
