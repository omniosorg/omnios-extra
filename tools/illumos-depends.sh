#!/bin/ksh -e

[ -z "$1" ] && echo "Syntax: $0 <path to prebuilt-illumos>" && exit 1

illumos="$1"
repo="$illumos/packages/i386/nightly-nd/repo.redist"

[ ! -d "$repo" ] && echo "$illumos does not look like a pre-built illumos." \
    && exit 1

# Get list of all packages:

all=`mktemp`
pkgrepo -s $repo list | sed 1d | awk '{print $2}' | sort > $all

depends=`mktemp`
pkg contents -rm -g $repo \* | sed -n '
	/^depend / {
		s/.*pkg:\///
		s/@.*//
		s/ .*//
		p
	}
' | sort | uniq > $depends

comm -13 $all $depends

rm -f $all $depends

