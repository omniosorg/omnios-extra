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

# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mg
VER=3.7
VERHUMAN=$VER
PKG=ooce/editor/mg
SUMMARY="emacs-like text editor"
DESC="mg is intended to be a small, fast, and portable editor for people "
DESC+="who can't (or don't want to) run emacs for one reason or another, "
DESC+="or are not familiar with the vi(1) editor. It is compatible with "
DESC+="emacs because there shouldn't be any reason to learn more editor "
DESC+="types than emacs or vi(1). "

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64
test_relver '>=' 151054 && set_clangver

SKIP_LICENCES=UNLICENSE

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS+="
    --prefix=$PREFIX
    --sysconfdir=/etc$OPREFIX
"

set_mirror "$GITHUB/troglobit/$PROG/archive"
set_checksum sha256 \
    df49b6cb872702f75b8c4ae3fbbf154a4a16e7297c62b84443a1d2a887bf7da1

CPPFLAGS+=" -I/usr/include/ncurses"

init
download_source v$VER $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
