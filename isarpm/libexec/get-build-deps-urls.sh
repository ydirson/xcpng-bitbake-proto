#! /bin/sh
set -e

SPECFILE="$1"
OUTDIR="$2"

# args sanity check
test -f "$SPECFILE"
test -d "$OUTDIR"

cd "$OUTDIR"
# safety
test -f "$SPECFILE"

rpmspec -q "$SPECFILE" --buildrequires | while read breq; do
    if rpm -q --whatprovides "$breq" 2>&1 >/dev/null; then
        echo >&2 "skipping installed/provided package: $breq"
        continue
    fi
    dnf download --quiet --resolve --url "$breq"
done
