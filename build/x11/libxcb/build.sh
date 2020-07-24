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

. ../../../lib/functions.sh

PROG=libxcb
VER=1.14
PSTUBVER=0.1
PKG=ooce/x11/library/libxcb
SUMMARY="libxcb"
DESC="X protocol C-language Binding (XCB)"

. $SRCDIR/../common.sh

BUILD_DEPENDS_IPS="
    ooce/x11/header/xcb-protocols
    ooce/x11/library/libxau
"

init
prep_build

######################################################################

build_dependency -merge libpthread-stubs libpthread-stubs-$PSTUBVER \
    x11/libpthread-stubs libpthread-stubs $PSTUBVER

addpath PKG_CONFIG_PATH32 $DEPROOT$PREFIX/lib/pkgconfig
addpath PKG_CONFIG_PATH64 $DEPROOT$PREFIX/lib/$ISAPART64/pkgconfig

######################################################################

PYTHONPATH+=":$PREFIX/lib/python$PYTHONVER/vendor-packages"
export PYTHONPATH

download_source x11/$PROG $PROG $VER
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
