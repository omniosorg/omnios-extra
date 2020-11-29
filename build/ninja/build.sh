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

PROG=ninja
PKG=ooce/developer/ninja
VER=1.10.2
SUMMARY="Ninja"
DESC="A small build system with a focus on speed"

set_arch 64

CONFIGURE_OPTS_64="
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_BUILD_TYPE=Release
"

TESTSUITE_MAKE="./ninja_test"
MAKE_TESTSUITE_ARGS=

init
download_source $PROG "v$VER"
patch_source
prep_build cmake
build -noctf    # C++
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
