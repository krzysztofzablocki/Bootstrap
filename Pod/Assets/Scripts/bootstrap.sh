#!/bin/sh

if [ "$#" -eq 0 ] ; then
    ENABLE_LINES=1
    ENABLE_TODO=1
    ENABLE_PERUSER=1
    ENABLE_BUILDNBR=1
    ENABLE_ICONVERSIONING=1
else
    ENABLE_LINES=0
    ENABLE_TODO=0
    ENABLE_PERUSER=0
    ENABLE_BUILDNBR=0
    ENABLE_ICONVERSIONING=0
fi

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
	-l)
	    ENABLE_LINES=1
	    shift
	    ;;
	-t)
	    ENABLE_TODO=1
	    shift
	    ;;
	-u)
	    ENABLE_PERUSER=1
	    shift
	    ;;
	-n)
	    ENABLE_BUILDNBR=1
	    shift
	    ;;
	-i)
	    ENABLE_ICONVERSIONING=1
	    ENABLE_BUILDNBR=1
	    shift
	    ;;
	*)
            # unknown option
	    echo Error: Unknown option $key 1>&2
	    exit 1
	    ;;
    esac
    shift
done

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${DIR}" ]]; then DIR="${PWD}"; fi

if [ "$ENABLE_BUILDNBR" -eq 1 ] ; then
    "${DIR}/buildNumber.sh"
fi

if [ "$ENABLE_ICONVERSIONING" -eq 1 ] ; then
    "${DIR}/iconVersioning.sh"
fi

if [ "$ENABLE_LINES" -eq 1 ] ; then
    "${DIR}/lines.sh"
fi

if [ "$ENABLE_TODO" -eq 1 ] ; then
"${DIR}/todo.sh"
fi
if [ "$ENABLE_PERUSER" -eq 1 ] ; then
    "${DIR}/user.sh"
fi

bundled_plist=$(find "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" -name "KZBEnvironments.plist" | tr -d '\r')
bundled_settings=$(find "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" -name "Settings.bundle" | tr -d '\r')
src_plist=$(find "${SRCROOT}" -name "KZBEnvironments.plist" | tr -d '\r')

if [[ "${CONFIGURATION}" == *Release*  ]]; then
  env -i xcrun -sdk macosx swift "${DIR}/processEnvironments.swift" "${bundled_plist}" "${src_plist}" "${bundled_settings}" "PRODUCTION"
else
  env -i xcrun -sdk macosx swift "${DIR}/processEnvironments.swift" "${bundled_plist}" "${src_plist}" "${bundled_settings}"
fi
