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

. ../../lib/functions.sh

PROG=iozone
VER=3.488
VERHUMAN=$VER
PKG=ooce/system/test/iozone
SUMMARY="IOzone - filesystem benchmark"
DESC="$SUMMARY"

OVER=${VER/./_}

set_builddir "$PROG$OVER/src/current"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

set_arch 64

SKIP_LICENCES=iozone

# No configure
configure64() { :; }

make_prog() {
    logmsg "--- make"
    logcmd $MAKE Solaris10gcc-64 \
        || logerr "--- make failed"
}

make_install() {
    logcmd mkdir -p "$DESTDIR$PREFIX/bin" || logerr "--- creating bin failed"
    logcmd cp "$TMPDIR/$BUILDDIR/"* "$DESTDIR$PREFIX/bin" \
        || logerr "--- copying $PROG failed"

    logcmd mkdir -p "$DESTDIR$PREFIX/share/man/man1" \
        || logerr "--- creating man1 failed"
    logcmd cp "$TMPDIR/$BUILDDIR/../../docs/$PROG.1" "$DESTDIR$PREFIX/share/man/man1" \
        || logerr "--- copying man page failed"
}

init
download_source $PROG "$PROG$OVER"
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
