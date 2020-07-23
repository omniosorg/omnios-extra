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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=zrepl
PKG=ooce/system/zrepl
VER=0.2.1
SUMMARY="$PROG - ZFS replication"
DESC="$PROG is a one-stop, integrated solution for ZFS replication"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_gover 1.14

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

GOOS=illumos
GOARCH=amd64
export GOOS GOARCH

build() {
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logmsg "Building 64-bit"
    logcmd $MAKE || logerr "Build failed"

    popd >/dev/null
}

init
clone_go_source $PROG $PROG v$VER
patch_source
prep_build
build
install_go artifacts/$PROG-$GOOS-$GOARCH
install_smf system zrepl.xml zrepl
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
