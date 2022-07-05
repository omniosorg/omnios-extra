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
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/build.sh

PROG=uefivars
VER=1.0.0
PKG=ooce/util/uefivars
SUMMARY="UEFI variable store firmware volume utility"
DESC="Utility for inspecting and manipulating a UEFI variable store"

BUILD_DEPENDS_IPS=ooce/developer/rust

set_mirror "$GITHUB/citrus-it/$PROG/releases/download"
set_arch 64

init
download_source v$VER $PROG $VER
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
