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

# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=llvm
PKG=ooce/developer/llvm-80
VER=8.0.1
SUMMARY="Low Level Virtual Machine compiler infrastructure"
DESC="A collection of modular and reusable compiler and toolchain technologies"

set_arch 64
set_builddir $PROG-$VER.src

LIC=UIUC
SKIP_LICENCES=$LIC

MAJVER=${VER%.*}
PATCHDIR=patches-${MAJVER//./}

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DLICENCE=$LIC
"

CMAKE="cmake -G Ninja"
MAKE=/opt/ooce/bin/ninja
TESTSUITE_MAKE=$MAKE

CONFIGURE_OPTS_64=
CONFIGURE_OPTS_WS_64="
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_COMPILER=\"$CC\"
    -DCMAKE_CXX_COMPILER=\"$CXX\"
    -DCMAKE_CXX_LINK_FLAGS=\"$LDFLAGS64\"
    -DLLVM_BUILD_LLVM_DYLIB=ON
    -DLLVM_INCLUDE_BENCHMARKS=OFF
    -DLLVM_INSTALL_UTILS=ON
    -DLLVM_LINK_LLVM_DYLIB=ON
    -DPYTHON_EXECUTABLE=\"$PYTHON\"
"

init
download_source $PROG $PROG $VER.src
patch_source
prep_build cmake
build
run_testsuite check-all
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
