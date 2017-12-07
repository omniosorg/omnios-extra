#!/usr/bin/bash
#
# {{{ CDDL HEADER
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
# }}}
#
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PKG=entire
VER=0.5.11
SUMMARY="Builds the OmniOS entire meta-package"
DESC="$SUMMARY"

create_manifest_header()
{
    local mf=$1
    cat << EOM > $mf
set name=pkg.fmri value=pkg://@PKGPUBLISHER@/entire@11,5.11-@PVER@
set name=pkg.depend.install-hold value=core-os
set name=pkg.summary value="Minimal set of core system packages"
set name=pkg.description value="Minimal set of core system packages"
EOM
}

add_constraints()
{
	local cmf=$1
	local src=$2

	egrep -v '^ *$|^#' $src | while read pkg ver typ; do
		if [ -z "$pkg" -o -z "$ver" -o -z "$typ" ]; then
			logerr "Bad package line, $pkg/$ver/$typ"
		fi
		echo "depend fmri=$pkg@$ver,5.11-@PVER@ type=$typ" >> $cmf
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
add_constraints $manifest $SRCDIR/entire.pkg

publish_pkg $manifest
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
