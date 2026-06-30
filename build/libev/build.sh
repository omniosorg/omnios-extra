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

. ../../lib/build.sh

PROG=libev
VER=4.33
PKG=ooce/library/libev
SUMMARY="libev"
DESC="High-performance event loop library"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

# As of r151059 we have stopped shipping the libevent v1.x compatibility
# header with libev, since the real libevent is shipped as a core package.
# Use an alternate mog file on older releases so the header is not dropped
# there.
test_relver '<' 151059 && LOCAL_MOG_FILE=prer59.mog

CONFIGURE_OPTS="
    --disable-static
    ac_cv_header_sys_inotify_h=no
    ac_cv_func_inotify_init1=no
"

CPPFLAGS+=" -D_REENTRANT"
CFLAGS+=" -D_REENTRANT"

init
download_source $PROG $PROG $VER
prep_build
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
