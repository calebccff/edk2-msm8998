#!/bin/bash
##### Change this to add device #####
DEVICES=(
	taimen
	cheeseburger
)
#####################################
function _help(){
	echo "Usage: build.sh --device DEV"
	echo
	echo "Build edk2 for Qualcomm msm8998 platform."
	echo
	echo "Options: "
	echo "	--device DEV, -d DEV: build for DEV. (${DEVICES[*]})"
	echo "	--help, -h:           show this help."
	echo
	echo "MainPage: https://github.com/calebccff/edk2-msm8998"
	exit "${1}"
}
cd "$(dirname "$0")"
if ! [ -f Msm8998Pkg/Msm8998Pkg.dsc ]
then	echo "cannot find Msm8998Pkg/Msm8998Pkg.dsc" >&2
	exit 1
fi
typeset -l DEVICE
DEVICE=""
OPTS="$(getopt -o d:h -l device:,help -n 'build.sh' -- "$@")"||exit 1
eval set -- "${OPTS}"
while true
do	case "${1}" in
		-d|--device)DEVICE="${2}";shift 2;;
		-h|--help)_help 0;shift;;
		--)shift;break;;
		*)_help 1;;
	esac
done
[ -z "${DEVICE}" ]&&_help 1
HAS=false
for i in "${DEVICES[@]}"
do	[ "${i}" == "${DEVICE}" ]||continue
	HAS=true
	break
done
if [ "${HAS}" != "true" ]
then	echo "build.sh: unknown build target device ${DEVICE}." >&2
	exit 1
fi
_EDK2="$(realpath "$PWD/../edk2")"
_EDK2_PLATFORMS="$(realpath "$PWD/../edk2-platforms")"
if ! [ -d "${_EDK2}" ]
then	echo "${_EDK2} not found, please see README.md" >&2
	exit 1
fi
if ! [ -d "${_EDK2_PLATFORMS}" ]
then	echo "${_EDK2_PLATFORMS} not found, please see README.md" >&2
	exit 1
fi
set -e
export PACKAGES_PATH="$_EDK2:$_EDK2_PLATFORMS:$PWD"
export WORKSPACE="$PWD/workspace"
source ../edk2/edksetup.sh
[ -d "${WORKSPACE}" ]||mkdir "${WORKSPACE}"
set -x
make -C ../edk2/BaseTools -j "$(nproc)"
# based on the instructions from edk2-platform
rm -f "boot_${DEVICE}.img" uefi_img
# not actually GCC5, it's GCC7 on Ubuntu 18.04.
GCC5_AARCH64_PREFIX=aarch64-linux-gnu- build -s -n 0 -a AARCH64 -t GCC5 -p "Msm8998Pkg/${DEVICE}.dsc"
gzip -c < workspace/Build/Msm8998Pkg/DEBUG_GCC5/FV/MSM8998PKG_UEFI.fd > "uefi-${DEVICE}.img"
cat "uefi-${DEVICE}.img" "device_specific/${DEVICE}.dtb" > "uefi-${DEVICE}.img-dtb"
echo > ramdisk
abootimg --create "boot-${DEVICE}.img" -k "uefi-${DEVICE}.img-dtb" -r ramdisk
echo "Build done: boot-${DEVICE}.img"
