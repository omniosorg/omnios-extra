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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=llvm
PKG=ooce/developer/llvm-14
VER=14.0.0rc4
SUMMARY="Low Level Virtual Machine compiler infrastructure"
DESC="A collection of modular and reusable compiler and toolchain technologies"

if [ $RELVER -lt 151041 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

set_arch 64
set_clangver
set_builddir $PROG-project-$VER.src/$PROG

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

MAJVER=${VER%%.*}
set_patchdir patches-$MAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
    -DVERSION=$MAJVER
"

CONFIGURE_OPTS_64=
CONFIGURE_OPTS_WS_64="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_C_COMPILER=\"$CC\"
    -DCMAKE_CXX_COMPILER=\"$CXX\"
    -DCMAKE_C_LINK_FLAGS=\"$LDFLAGS64\"
    -DCMAKE_CXX_LINK_FLAGS=\"$LDFLAGS64\"
    -DLLVM_BUILD_LLVM_DYLIB=ON
    -DLLVM_INCLUDE_BENCHMARKS=OFF
    -DLLVM_INSTALL_UTILS=ON
    -DLLVM_LINK_LLVM_DYLIB=ON
"

init
download_source $PROG $PROG-project $VER.src
patch_source
prep_build cmake+ninja
build -noctf    # C++
strip_install
VERHUMAN=$VER
VER=${VER%rc*} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
