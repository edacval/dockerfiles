#!/usr/bin/bash

set -e

BTRFSPATH="/var/lib/docker/btrfs/subvolumes"

CNAME='logstash'
UGID=130000
PRIMPATH="/logstash"

BASEPATH="/srv/docker/logstash"
CONFIGPATH="$BASEPATH/config"
DATAPATH="$BASEPATH/data"
SINCEDBPATH="$DATAPATH/sincedb"
ULOGDPATH="/var/log/ulogd"

RTESTPATHS=(
    "$CONFIGPATH"
    "$ULOGDPATH"
    "$DATAPATH"
)

for testpath in ${RTESTPATHS[@]}; do
    if ! sudo --user="#$UGID" test -r "$testpath"; then
        echo 'Read denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif sudo --user="#$UGID" test -w "$testpath"; then
        echo 'Write allowed!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -x "$testpath"; then
        echo 'Execute denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    fi
done

WTESTPATHS=(
    "$SINCEDBPATH"
)

for testpath in ${WTESTPATHS[@]}; do
    if ! sudo --user="#$UGID" test -r "$testpath"; then
        echo 'Read denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -w "$testpath"; then
        echo 'Write denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    elif ! sudo --user="#$UGID" test -x "$testpath"; then
        echo 'Execute denied!'
        echo "UGID: $UGID"
        echo "Path: $testpath"
        exit 1
    fi
done

docker create \
    --volume="$CONFIGPATH:$PRIMPATH/config:ro" \
    --volume="$DATAPATH:$PRIMPATH/data" \
    --volume="$ULOGDPATH:$PRIMPATH/host/ulogd:ro" \
    --net=none \
    --name="$CNAME" \
    nfnty/arch-logstash

CID="$(docker inspect --format='{{.Id}}' "$CNAME")"

cd "$BTRFSPATH/$CID"
setfattr --name=user.pax.flags --value=em usr/lib/jvm/java-8-openjdk/jre/bin/java
