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
VER=0.5.5
SUMMARY="github-cli"
DESC="The GitHub CLI tool"

PROGB=cli
GITHUB=https://github.com/cli

set_arch 64
set_gover 1.13

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

BUILD_DEPENDS_IPS="developer/versioning/git"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

# Respect environmental overrides for these to ease development.
: ${GH_SOURCE_REPO:=$GITHUB/$PROGB}
: ${GH_SOURCE_BRANCH:=v$VER}

clone_source() {
    clone_github_source $PROGB \
        "$GH_SOURCE_REPO" "$GH_SOURCE_BRANCH"

    BUILDDIR+=/$PROGB
}

get_deps() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    export GOPATH=$TMPDIR/$BUILDDIR/_deps

    logmsg "getting dependencies (in order to patch them)..."
    logcmd go get -u ./...

    logmsg "fixing permissions on modules (in order to be able to patch them)..."
    logcmd chmod -R u+w $GOPATH

    popd >/dev/null
}

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
clone_source
get_deps
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
