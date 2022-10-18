#!/usr/bin/bash
#
# {{{
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
# Copyright 2021 Oxide Computer Company
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
#

. ../../lib/build.sh

PROG=ncdu
VER=2.2
PKG=ooce/util/ncdu
SUMMARY="$PROG - NCurses Disk Usage"
DESC="Disk usage analyzer with an ncurses interface"

set_arch 64
set_clangver # zig requires CC to be set

BUILD_DEPENDS_IPS="ooce/developer/zig"

# No configure
configure64() { :; }

# enable SSP and avoid BMI instructions
export ZIG_FLAGS="-Drelease-safe -Dcpu=opteron"

MAKE_INSTALL_ARGS="PREFIX=$PREFIX"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build -noctf
strip_install
make_package
clean_up

# vim:ts=4:sw=4:et:fdm=marker
