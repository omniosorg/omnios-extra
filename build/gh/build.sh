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

# Copyright 2020 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=gh
PKG=ooce/util/gh
VER=0.6.1
SUMMARY="github-cli"
DESC="The GitHub CLI tool"

set_arch 64
set_gover 1.14

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

RUN_DEPENDS_IPS="developer/versioning/git"

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building 64-bit"
    logcmd $MAKE || logerr "Build failed"

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $TMPDIR/$BUILDDIR/bin/$PROG $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"
}

init
clone_go_source cli cli v$VER
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
