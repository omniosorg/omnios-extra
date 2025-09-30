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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=libusb
VER=1.0.29
PKG=ooce/library/libusb-1
SUMMARY="libusb 1.0"
DESC="A cross-platform library to access USB devices"

test_relver '>=' 151055 && set_clangver

BUILD_DEPENDS_IPS="
    system/header/header-ugen
    system/header/header-usb
"

CONFIGURE_OPTS="--disable-static"

init
download_source $PROG $PROG $VER
patch_source
run_autoreconf -fi
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
