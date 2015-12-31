#!/usr/bin/bash

set -o errexit -o noclobber -o noglob -o nounset -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CNAME="${1}"

source "${SCRIPTDIR}/var.sh"
source "${SCRIPTDIR}/../_misc/permissions.sh"

perm_user_ro "${PATH_ETC}"
perm_user_rw "${PATH_LIB}"
perm_user_rw "${PATH_LOG}"
perm_user_rw "${PATH_RUN}" '-maxdepth 0'
perm_user_rw "${PATH_TMP}"
