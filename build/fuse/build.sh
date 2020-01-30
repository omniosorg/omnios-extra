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

. ../../lib/functions.sh

PROG=fuse
VER=1.4
PKG=ooce/driver/fuse
SUMMARY="$PROG"
DESC="fuse kernel module for illumos"

set_gccver $ILLUMOS_GCC_VER

set_arch 64
set_builddir "illumos-${PROG}fs-Version-$VER/kernel"

MAKE=/usr/bin/dmake
# build requires ctf tools
PATH+=":/opt/onbld/bin/i386"

# No configure
configure64() { :; }

init
download_source $PROG Version-$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
