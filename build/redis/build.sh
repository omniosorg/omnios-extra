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
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=redis
VER=8.10.3
PKG=ooce/database/redis
SUMMARY="$PROG - remote dictionary server"
DESC="An in-memory key–value database"

set_arch 64

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

MAKE_INSTALL_ARGS+=" -j$MJOBS"

pre_configure() {
    typeset arch=$1

    subsume_arch $arch CFLAGS
    export CFLAGS

    logcmd $RM -rf $TMPDIR$PBUILDDIR/src/modules/*/src \
        || logerr "failed to rm modules"

    logcmd $PERL -i -pe 's/^loadmodule/# loadmodule/' \
        $TMPDIR$PBUILDDIR/src/$PROG.conf || logerr "patching config"

    export PREFIX DESTDIR

    # No configure
    false
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
xform files/$PROG-template.xml > $TMPDIR/$PROG.xml
install_smf ooce $PROG.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
