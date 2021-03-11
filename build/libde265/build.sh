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

PROG=libde265
VER=1.0.8
PKG=ooce/library/libde265
SUMMARY="h.265 codec implementation"
DESC="Open source implementation of the h.265 video codec"

forgo_isaexec

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="
    --disable-static
    --disable-encoder
    --disable-dec265
    --disable-sherlock265
"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
