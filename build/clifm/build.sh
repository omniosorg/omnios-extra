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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=clifm
VER=1.26.3
PKG=ooce/application/clifm
SUMMARY="$PROG"
DESC="A shell-like, text-based terminal file manager"

set_arch 64
set_clangver

build() {
    pushd $TMPDIR/$BUILDDIR > /dev/null

    logmsg "Building $PROG"

    logcmd $MAKE -f misc/solaris/Makefile || logerr "Unable to build $PROG"

    logmsg "Installing $PROG"
    logcmd $MAKE -f misc/solaris/Makefile INSTALL=install PREFIX=$DESTDIR/$PREFIX install || logerr "Unable to install $PROG"

    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
