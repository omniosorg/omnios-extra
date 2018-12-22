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
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=mbuffer
VER=20181119
VERHUMAN=$VER
PKG=ooce/system/mbuffer
SUMMARY="$PROG - measuring buffer"
DESC="$PROG is a tool for buffering data streams"

OPREFIX=$PREFIX
PREFIX+="/$PROG"
XFORM_ARGS=" -DOPREFIX=${OPREFIX#/} -DPROG=$PROG"

# Build 64-bit only and skip the arch-specific directories
BUILDARCH=64
CONFIGURE_OPTS="
    --bindir=$PREFIX/bin
"

reset_configure_opts

init
download_source $PROG $PROG $VER
patch_source
prep_build
run_autoconf
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
