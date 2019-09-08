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

# Copyright 2019 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=top
PKG=ooce/system/top
VER=3.8
BETA=1
SUMMARY="top"
DESC="Display and update information about the top cpu processes"

BUILDDIR="$PROG-${VER}beta$BETA"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --disable-dualarch
"

init
download_source $PROG $PROG ${VER}beta$BETA
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
