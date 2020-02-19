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

PROG=rclone
PKG=ooce/network/rclone
VER=1.51.0
SUMMARY="rsync for cloud storage"
DESC="A command line program to sync files and directories to and from "
DESC+="different cloud storage providers"

GITHUB=https://github.com/$PROG

set_arch 64
set_gover 1.13

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

BUILD_DEPENDS_IPS="developer/versioning/git"

XFORM_ARGS="-DPROG=$PROG"

# rclone build wants GNU cp
export PATH="/usr/gnu/bin:$PATH"

# Respect environmental overrides for these to ease development.
: ${RCLONE_SOURCE_REPO:=$GITHUB/$PROG}
: ${RCLONE_SOURCE_BRANCH:=v$VER}

clone_source() {
    clone_github_source $PROG \
        "$RCLONE_SOURCE_REPO" "$RCLONE_SOURCE_BRANCH"

    BUILDDIR+=/$PROG
}

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    export GOPATH=$TMPDIR/$BUILDDIR/proto
    logmsg "Building 64-bit"
    logcmd $MAKE || logerr "Build failed"

    popd >/dev/null
}

install() {
    logcmd mkdir -p $DESTDIR/$PREFIX/bin || logerr "mkdir"
    logcmd cp $GOPATH/bin/$PROG $DESTDIR/$PREFIX/bin/$PROG \
        || logerr "Cannot install binary"
}

init
clone_source
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
