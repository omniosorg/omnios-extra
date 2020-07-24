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

PROG=xcb-proto
VER=1.14
PKG=ooce/x11/header/xcb-protocols
SUMMARY="xcb-proto"
DESC="X protocol C-language Binding (XCB): Protocol descriptions"

. $SRCDIR/../common.sh

# required to pick up python3
export PYTHON

init
download_source x11/$PROG $PROG $VER
prep_build
patch_source
build
python_vendor_relocate
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
