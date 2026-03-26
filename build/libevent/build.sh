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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libevent
VER=2.1.12
PKG=ooce/library/libevent
SUMMARY="libevent"
DESC="Event notification library"

forgo_isaexec
set_clangver

set_builddir "$PROG-$VER-stable"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_standard POSIX+EXTENSIONS CFLAGS
LDFLAGS+="-lnsl -lresolv"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --disable-static
    ac_cv_func_epoll_ctl=no
    ac_cv_func_epoll_ctl=no
"
CONFIGURE_OPTS[i386]="
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --libdir=$OPREFIX/lib/amd64
"
CONFIGURE_OPTS[aarch64]+="
    --libdir=$OPREFIX/lib
"

init
download_source $PROG "$PROG-$VER-stable"
prep_build
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
