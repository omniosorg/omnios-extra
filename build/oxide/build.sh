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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=oxide
VER=0.2.0
PKG=ooce/util/oxide
SUMMARY="$PROG"
DESC="Oxide SDK and CLI"

BUILD_DEPENDS_IPS=ooce/developer/rust

REPO=$GITHUB/oxidecomputer/$PROG.rs

set_arch 64

# oxide contains BMI instructions even when built on an older CPU
BMI_EXPECTED=1

# https://www.illumos.org/issues/14659
test_relver '<' 151043 && STRIP=gstrip

init
clone_github_source $PROG $REPO v$VER
append_builddir $PROG
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
