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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=radare2
PKG=ooce/developer/radare2
VER=5.9.0
SUMMARY="A low-level software forensics tool"
DESC="$PROG - $SUMMARY"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
set_standard XPG6 CFLAGS

NO_SONAME_EXPECTED=1
SKIP_RTIME_CHECK=1

PKGDIFFPATH="${PREFIX#/}/share/$PROG"
PKGDIFF_HELPER="
    s:$PKGDIFFPATH/[0-9][0-9.]*:$PKGDIFFPATH/VERSION:
"

export PATH=$GNUBIN:$PATH
CFLAGS+=" -fPIC"
LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64 -L$OPREFIX/lib/amd64"
LDFLAGS[amd64]+=" -R$PREFIX/lib/amd64"
# Some of the libraries have large enumerations
CTF_FLAGS+=" -sm"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DPKGROOT=$PROG
"

init
download_source $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
