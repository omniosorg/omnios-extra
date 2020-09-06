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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Copyright 2020 Stephen Gregoratto

. ../../lib/functions.sh

PROG=hyperfine
VER=1.10.0
PKG=ooce/util/hyperfine
SUMMARY="benchmarking tool"
DESC="$PROG is a command-line benchmarking tool that provides statistics about command execution time."

BUILD_DEPENDS_IPS=ooce/developer/rust

set_arch 64

build() {
    logmsg "Building 64-bit"
    pushd $TMPDIR/$BUILDDIR >/dev/null
    args="--release"
    logcmd cargo build $args || logerr "build failed"
    popd >/dev/null
}

install() {
    logmsg "Installing"
    pushd $TMPDIR/$BUILDDIR >/dev/null

    logcmd mkdir -p $DESTDIR/$PREFIX/bin
    logcmd cp target/release/$PROG $DESTDIR/$PREFIX/bin/$PROG || logerr "cp failed"

    logcmd mkdir -p $DESTDIR/$PREFIX/share/man/man1
    logcmd cp doc/$PROG.1 $DESTDIR/$PREFIX/share/man/man1/ || logerr "cp failed"

    popd >/dev/null
}

init
download_source $PROG v$VER
patch_source
prep_build
build
install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
