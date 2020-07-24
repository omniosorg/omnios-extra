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

PROG=libX11
VER=1.6.9
PKG=ooce/x11/library/libx11
SUMMARY="libX11"
DESC="X11 core protocol client library"

. $SRCDIR/../common.sh

BUILD_DEPENDS_IPS="
    ooce/x11/header/x11-protocols
    ooce/x11/library/xtrans
    ooce/x11/library/libxcb
"

init
download_source x11/$PROG $PROG $VER
prep_build
patch_source
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
