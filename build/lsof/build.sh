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

PROG=lsof
PKG=ooce/file/lsof
VER=4.93.2
SUMMARY="List open files"
DESC="Report a list of all open files and the processes that opened them"

# This component does not yet build with gcc 10
[ $GCCVER = 10 ] && set_gccver 9

SKIP_LICENCES=lsof

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

configure64() {
    logmsg "--- configure (64-bit)"
    yes | logcmd ./Configure solaris || logerr "--- Configure failed"
}

make_install64() {
    logmsg "--- make install"
    mkdir -p $DESTDIR$PREFIX/share/man/man8
    mkdir -p $DESTDIR$PREFIX/bin
    logcmd cp $TMPDIR/$BUILDDIR/${PROG^}.8 \
        $DESTDIR$PREFIX/share/man/man8/$PROG.8 \
        || logerr "--- Make install failed"
    logcmd cp $TMPDIR/$BUILDDIR/$PROG $DESTDIR$PREFIX/bin/$PROG \
        || logerr "--- Make install failed"
}

init
download_source $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
