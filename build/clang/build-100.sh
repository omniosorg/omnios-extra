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

PROG=clang
PKG=ooce/developer/clang-100
VER=10.0.0
SUMMARY="C language family frontend for LLVM"
DESC="The Clang project provides a language front-end and tooling "
DESC+="infrastructure for languages in the C language family (C, C++, "
DESC+="Objective C/C++, OpenCL, CUDA, and RenderScript) for the LLVM project"

set_arch 64
set_builddir $PROG-$VER.src

MAJVER=${VER%.*}
PATCHDIR=patches-${MAJVER//./}

BUILD_DEPENDS_IPS="ooce/developer/llvm-${MAJVER//./}"
# Using the = prefix to require the specific matching version of llvm
RUN_DEPENDS_IPS="
    =$BUILD_DEPENDS_IPS@$MAJVER
    =ooce/developer/compiler-rt-${MAJVER//./}@$MAJVER
    ooce/developer/compiler-rt-${MAJVER//./}
"

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DLICENCE=Apache2
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
    -DGCC_INSTALL_PREFIX=\"$GCCPATH\"
    -DCLANG_DEFAULT_LINKER=\"/usr/bin/ld\"
    -DCLANG_DEFAULT_RTLIB=compiler-rt
    -DLLVM_CONFIG=\"$OPREFIX/llvm-$MAJVER/bin/llvm-config\"
    -DPYTHON_EXECUTABLE=\"$PYTHON\"
"

init
download_source $PROG $PROG $VER.src
patch_source
prep_build cmake
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
