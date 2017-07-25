#!/bin/bash -e

# we use this script to fetch the packer install package for linux or windows

function fail() {
    echo error: $*
    cd $MYPWD
    exit 1
}

MYPWD=`pwd`

MYCOMPANY=mycompany

if [ "${MYOSTYPE}" == "windows" ]; then
    PACKERVERSION=packer_1.0.0_${MYOSTYPE}_amd64
    PACKERCHECKSUM=54b2c92548f0a4f434771703f083b6e0fbbf73a8bf81963fd43e429d2561a4e0
elif [ "${MYOSTYPE}" == "linux" ]; then
    PACKERVERSION=packer_1.0.0_${MYOSTYPE}_amd64
    PACKERCHECKSUM=ed697ace39f8bb7bf6ccd78e21b2075f53c0f23cdfb5276c380a053a7b906853
else
    fail "unknown os type"
fi

PACKERZIPFILE=${PACKERVERSION}.zip

if [ -z "${MYROOT}" ]; then
    echo "please load env-${MYOSTYPE}.sh in your shell window like this:"
    fail ". env-${MYOSTYPE}.sh";
fi

OPTSTRING="t:"

# the target network type, either "direct" or "mycompany"
TARGETNETTYPE=

while [[ $* ]]
do
    OPTIND=1
    echo got this: $1
    if [[ $1 =~ ^- ]]
    then
	echo ">> got option"
	getopts ${OPTSTRING} opt
	case $opt in
	    t)
		TARGETNETTYPE=${OPTARG}
		shift
		;;
	esac
    fi
    shift
done

if [ "${TARGETNETTYPE}" == "direct" ]; then
    echo "got target net type direct"
elif [ "${TARGETNETTYPE}" == "${MYCOMPANY}" ]; then
    echo "got target net type ${MYCOMPANY}"
elif [ "${TARGETNETTYPE}" == "" ]; then
    echo "got no target net type, defaulting to \"direct\"."
    echo "you can change this with the \"-t ${MYCOMPANY}\" parameter."
    TARGETNETTYPE=direct
else
    fail "got unknown target net type, please set it with -t, e.g. \"-t direct\" or \"-t ${MYCOMPANY}\"."
fi

PACKERFETCHURL=
if [ "${TARGETNETTYPE}" == "direct" ]; then
    PACKERFETCHURL=https://releases.hashicorp.com/packer/1.0.0/${PACKERZIPFILE}
fi

if [ "${TARGETNETTYPE}" == "${MYCOMPANY}" ]; then
    PACKERFETCHURL=http://10.0.0.1/tools/${PACKERZIPFILE}
fi

if [ ! -d ${MYROOT}/downloads ]; then
    mkdir ${MYROOT}/downloads || fail "mkdir downloads"
fi

curl ${PACKERFETCHURL} -o ${MYROOT}/downloads/${PACKERZIPFILE} || fail "curl"

cd ${MYROOT}/downloads || fail "cd"
echo checking packer zip checksum
cat > ${PACKERZIPFILE}.sha256sums <<EOF
${PACKERCHECKSUM}  ${PACKERZIPFILE}
EOF
sha256sum -c ${PACKERZIPFILE}.sha256sums || fail "checksum error"

cd $MYPWD || fail "cd"

if [ -d ${MYROOT}/3rdparty/${PACKERVERSION} ]; then
    rm -r ${MYROOT}/3rdparty/${PACKERVERSION} || fail "rm old packer install"
fi

mkdir -p ${MYROOT}/3rdparty/${PACKERVERSION} || fail "mkdir"

(cd ${MYROOT}/3rdparty/${PACKERVERSION} && unzip ${MYROOT}/downloads/${PACKERZIPFILE}) || fail "unzip"

