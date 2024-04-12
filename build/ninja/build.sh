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

PROG=ninja
PKG=ooce/developer/ninja
VER=1.12.0
SUMMARY="Ninja"
DESC="A small build system with a focus on speed"

forgo_isaexec
test_relver '>=' 151043 && set_clangver

CONFIGURE_OPTS="-DCMAKE_BUILD_TYPE=Release"

TESTSUITE_MAKE="./ninja_test"
MAKE_TESTSUITE_ARGS=

TESTSUITE_SED='s/  *([0-9][0-9]*  *ms.*//'

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        -DCMAKE_INSTALL_PREFIX=$PREFIX
        -DCMAKE_INSTALL_LIBDIR=$PREFIX/${LIBDIRS[$arch]}
    "
}

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
