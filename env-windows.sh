# here we just add the scripts etc. to the PATH

export MYROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo MYROOT: ${MYROOT}

export PATH=${PATH}:${MYROOT}/bin
export PATH=${PATH}:${MYROOT}/bin/windows
export PATH=${PATH}:${MYROOT}/3rdparty/packer_1.0.0_windows_amd64

# by default python installs to this directory on windows
export PATH=${PATH}:/c/Python27:/c/Python27/Scripts
