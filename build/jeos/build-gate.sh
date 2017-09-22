#!/usr/bin/bash
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to licence terms.
#
# Load support functions
. ../../lib/functions.sh

PKG=incorporation/jeos/illumos-gate
VER=0.5.11
SUMMARY="Builds the OmniOS illumos-gate incorporation"
DESC="$SUMMARY $VER"

create_manifest_header()
{
    local mf=$1
    cat << EOM > $mf
set name=pkg.fmri value=pkg://@PKGPUBLISHER@/incorporation/jeos/illumos-gate@11,5.11-@PVER@
set name=pkg.depend.install-hold value=core-os.omnios
set name=pkg.description value="This incorporation constrains packages from illumos-gate."
set name=pkg.summary value="OmniOS Illumos incorporation"
EOM
}

#depend fmri=SUNWcs@0.5.11,5.11-@PVER@ type=incorporate
add_constraints()
{
    local mf=$1
    local repo=$2

    if [ ! -d "$repo" ]; then
	logerr "--- Package repo does not exist."
    else
	pkgrepo -s $repo list | sort -k2,2 | nawk '
	    BEGIN {
		ops["o"] = "Obsolete"
		ops["r"] = "Renamed"
	    }
	    $3 in ops {
	        printf("# %s: %s\n", ops[$3], $2)
		next
	    }
	    $1 == "on-nightly" {
		pkg = $2
		ver = $3
		# 1.6.0-0.151023:20170728T111351Z
		i = index(ver, "-")
		if (i) ver = substr(ver, 1, i - 1)
		printf("depend fmri=%s@%s,5.11-@PVER@ type=incorporate\n",
		    pkg, ver)
	  }' | fgrep -v -f $SRCDIR/illumos-gate.exclude >> $mf
    fi
}

publish_pkg()
{
    local pmf=$1

    sed -e "
		s/@PKGPUBLISHER@/$PKGPUBLISHER/g
		s/@RELVER@/$RELVER/g
		s/@PVER@/$PVER/g
        " < $pmf > $pmf.final

    pkgsend -s $PKGSRVR publish $pmf.final || bail "pkgsend failed"
}

init
prep_build
check_for_prebuilt 'packages/i386/nightly-nd/repo.redist/'
pkgrepo=$PREBUILT_ILLUMOS/packages/i386/nightly-nd/repo.redist

manifest=$TMPDIR/$PKGE.p5m
create_manifest_header $manifest
add_constraints $manifest $pkgrepo

if [ -z "$BATCH" ]; then
    logmsg "Manifest: $manifest"
    logmsg "Intentional pause: Last chance to sanity-check before publication!"
    ask_to_continue
fi
publish_pkg $manifest
clean_up

