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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=minicom
VER=2.8
PKG=ooce/terminal/minicom
SUMMARY="$PROG - terminal emulator"
DESC="$PROG is a text-based modem control and terminal emulator "
DESC+="program for unix-like operating systems."

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_builddir $PROG-v$VER

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="--enable-dfl-port=/dev/cua/b"

init
download_source $PROG $PROG v$VER
patch_source
prep_build autoconf -autoreconf
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
