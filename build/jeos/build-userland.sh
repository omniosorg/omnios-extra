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

PKG=incorporation/jeos/omnios-userland
VER=0.5.11
SUMMARY="Builds the OmniOS userland incorporation"
DESC="$SUMMARY $VER"

create_manifest_header()
{
    local mf=$1
    cat << EOM > $mf
set name=pkg.fmri value=pkg://@PKGPUBLISHER@/incorporation/jeos/omnios-userland@11,5.11-@PVER@
set name=pkg.depend.install-hold value=core-os.omnios
set name=pkg.summary value="Incorporation to constrain OmniOS userland packages to same build"
set name=pkg.description value="This package constrains OmniOS userland packages to the same build as osnet-incorporation."
EOM
}

#depend fmri=web/wget@1.19,5.11-@PVER@ type=incorporate

add_constraints()
{
	local cmf=$1
	local src=$2

	egrep -v '^ *$|^#' $src | while read pkg ver dash; do
		if [ -z "$pkg" -o -z "$ver" ]; then
			logerr "Bad package line, $pkg $ver"
		fi
		[ -z "$dash" ] && dash=0
		echo "depend facet.version-lock.$pkg=true"\
		    "fmri=$pkg@$ver,5.11-$dash.@RELVER@ type=incorporate" \
		    >> $cmf
	done
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

manifest=$TMPDIR/$PKGE.p5m
create_manifest_header $manifest
add_constraints $manifest $SRCDIR/omnios-userland.pkg

if [ -z "$BATCH" ]; then
    logmsg "Manifest: $manifest"
    logmsg "Intentional pause: Last chance to sanity-check before publication!"
    ask_to_continue
fi
publish_pkg $manifest
clean_up

