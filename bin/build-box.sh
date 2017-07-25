#!/bin/bash

# this script is used to generate the needed packer config
# files and to run the different build steps that are needed
# to create a vagrant box for a given distribution.

function usage() {
    cat <<EOF
usage:

  build-box.sh [options] [steps]

e.g.

  build-box.sh --targetnettype direct --boxversion 0.0.1 --distrel debian-9 step1 step2 step3

options:

--boxversion     this version is set in the resulting vagrant box.

--targetnettype  this target net type is used to tell if we want
                 to run a build step with a direct network connection
                 or with some company-special setup, e.g. proxy,
                 own package repos, etc.
                 The default value is "direct".
--fetchnettype (FIXME)
--distrel        this parameter is used to specify which distribution
                 and which release of it we want to build. distrel is
                 a short form for distribution_and_release

                 Available distribution releases: ubuntu-1604, debian-9,
                 fedora-25.

--clean          when this parameter is given, the build-box.sh script
                 automatically cleans a packer output directory of a
                 build step, if it does already exist, e.g. as from the
                 last build run.
--debug          print some debug output when generating the config
                 files and when running packer
EOF
}

function fail() {
    echo error: $*
    exit 1
}

if [ -z "${MYROOT}" ]; then
    echo "please load env-<OS>.sh in your shell window like this:"
    echo ". env-windows.sh";
    echo "or"
    fail ". env-linux.sh";
fi

# the name of my company,
# can be overriden in customized branches
MYCOMPANY=mycompany

# clean old packer outut dir or not
CLEAN_OUTPUT=

# print debug output or not
DEBUG=

# build this distrel, distrel is the short form for "distribution and release"
DISTREL=

# these are the steps we want to execute
STEPS=

# target network type, can be direct or $MYCOMPANY.
# used to add company-special workarounds for
# e.g. proxies, broken firewall rules, etc.
TARGETNETTYPE=

# the network type for fetching data, e.g. isos
FETCHNETTYPE=

# this variable holds the version that we want to have
# in the name of the box that will be built by step 3.
BOXVERSION=

OPTSTRING="gf:r:t:v:c"

while [[ $* ]]
do
    OPTARG=$2
    if [[ $1 =~ ^- ]]
    then
	case $1 in
	    -c | --clean)
		CLEAN_OUTPUT=1
		;;
	    -d | --debug)
		DEBUG=1
		;;
	    -r | --distrel)
		DISTREL=${OPTARG}
		shift
		;;
	    -t | --targetnettype)
		TARGETNETTYPE=${OPTARG}
		shift
		;;
	    -f | --fetchnettype)
		FETCHNETTYPE=${OPTARG}
		shift
		;;
	    -v | --boxversion)
		BOXVERSION=${OPTARG}
		shift
		;;
	esac
    else
	# add step to steps
	STEPS="${STEPS} $1"
    fi
    shift
done


# check that a distrel was given
if [ ! ${DISTREL} ]; then
    usage
    echo ""
    fail "you need to specify a distribution_release with the \"--distrel\" parameter. exiting"
fi

# check that a target net type was given
if [ ! ${TARGETNETTYPE} ]; then
    echo "setting default target net type to \"direct\"."
    TARGETNETTYPE=direct
fi


if [ "${TARGETNETTYPE}" == "${MYCOMPANY}" ]; then
    #    echo got mycompany target network type
    true
elif [ "${TARGETNETTYPE}" == "direct" ]; then
    #    echo got direct target network type
    true
else
    usage
    echo ""
    fail "got unknown target network type: \"${TARGETNETTYPE}\". please use \"--targetnettype ${MYCOMPANY}\" or \"--targetnettype direct\". exiting"
fi

# check that a fetch net type was given
if [ "${FETCHNETTYPE}" == "${MYCOMPANY}" ]; then
    #    echo got mycompany fetch network type
    true
elif [ "${FETCHNETTYPE}" == "direct" ]; then
    #    echo got direct fetch network type
    true
elif [ "${FETCHNETTYPE}" == "" ]; then
    # here we default a not-given fetch network type to the
    # given target network type
    FETCHNETTYPE=${TARGETNETTYPE}
else
    usage
    echo ""
    fail "got unknown fetch network type: \"${FETCHNETTYPE}\". please use \"--fetchnettype ${MYCOMPANY}\" or \"--fetchnettype direct\". exiting"
fi

# check that a box version was given
if [ ! ${BOXVERSION} ]; then
    usage
    echo ""
    fail "you need to specify a box version with the --boxversion parameter. please use e.g. \"--boxversion 0.0.1\". exiting"
fi

# check that the steps to be executed are not empty
if [ "" = "${STEPS}" ]; then
    usage
    echo ""
    fail "please set a step to execute. available steps: step1, step2, step3. example: \"build-box.sh step1\""
fi

# print our current config
echo DISTREL:       ${DISTREL}
echo STEPS:         ${STEPS}
echo BOXVERSION:    ${BOXVERSION}
echo TARGETNETTYPE: ${TARGETNETTYPE}
echo FETCHNETTYPE:  ${FETCHNETTYPE}
echo CLEAN_OUTPUT:  ${CLEAN_OUTPUT}


# make sure the build directoy exists
if [ ! -d ${MYROOT}/build ]; then
    mkdir ${MYROOT}/build || fail "mkdir build"
fi


echo generating packer json templates

DEBUG_GENERATE=
if [ "1" == "${DEBUG}" ]; then
    DEBUG_GENERATE=--debug
fi


# generate the packer config files from our
# config files
python ${MYROOT}/bin/generate-packer-templates.py \
--distrel ${DISTREL} \
--targetnettype ${TARGETNETTYPE} \
--fetchnettype ${FETCHNETTYPE} \
--boxversion ${BOXVERSION} \
${DEBUG_GENERATE} \
${STEPS} \
|| fail "generate-packer-templates.py"


# execute packer to build a step
function build_step() {
    STEP=$1
    echo building step $STEP

    # clean the output directory if needed. packer does not build
    # a step, if the ouput directory of that step does alreads exist.
    if [ "1" == "${CLEAN_OUTPUT}" ]; then
	echo cleaning step ${STEP}

	# the output directories are at output/"distrel"-"step"
	if [ -d ${MYROOT}/output/${DISTREL}-${STEP} ]; then
	    echo removing ${MYROOT}/output/${DISTREL}-${STEP}
	    rm -r ${MYROOT}/output/${DISTREL}-${STEP} || fail "clean failed"
	fi
    fi

    # we use json files with added comments for readability.
    # here we remove the comments, and then we use the
    # -stripped.json files later on
    JSONFILE=${MYROOT}/build/${DISTREL}-${STEP}.json
    JSONFILESTRIPPED=${MYROOT}/build/${DISTREL}-${STEP}-stripped.json

    # remove comments from json file
    cat ${JSONFILE} | sed -e "s:^[ \t]*//.*::g" > ${JSONFILESTRIPPED} || fail "json stripping failed."

    PACKER_OPTIONS=

    # use this to let packer wait for a keypress after each function that it executed,
    # useful for debugging packer scripts
    #PACKER_OPTIONS=${PACKER_OPTIONS} -debug
    if [ "1" == "${DEBUG}" ]; then
        PACKER_OPTIONS=${PACKER_OPTIONS} -debug
    fi

    # use this to tell packer to wait after an error occured.
    # this way you can interact with the vm, e.g. log into
    # it, so that you can debug the problem. without this switch
    # packer just deletes the failed vm and you cannot look
    # into it any more...
    #PACKER_OPTIONS=${PACKER_OPTIONS} --on-error=ask

    # speed up boot prompt typing speed
    export PACKER_KEY_INTERVAL=10ms

    # use this to let packer print debug log
    #export PACKER_LOG=1

    packer build ${PACKER_OPTIONS} ${JSONFILESTRIPPED} || fail "packer call failed."
}

for STEP in ${STEPS}; do
    echo executing step: ${STEP}
    build_step ${STEP}
done

echo "build-box.sh success"
