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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=clang
PKG=ooce/developer/clang-17
VER=17.0.2
SUMMARY="C language family frontend for LLVM"
DESC="The Clang project provides a language front-end and tooling "
DESC+="infrastructure for languages in the C language family (C, C++, "
DESC+="Objective C/C++, OpenCL, CUDA, and RenderScript) for the LLVM project"

min_rel 151047

set_arch 64
set_clangver
set_builddir llvm-project-$VER.src/$PROG

SKIP_RTIME_CHECK=1
NO_SONAME_EXPECTED=1

MAJVER=${VER%%.*}
MINVER=${VER%.*}
set_patchdir patches-$MAJVER

# Using the = prefix to require the specific matching version of llvm
BUILD_DEPENDS_IPS="=ooce/developer/llvm-$MAJVER@$VER"

RUN_DEPENDS_IPS="
    =ooce/developer/llvm-$MAJVER@$MINVER
    developer/gcc$GCCVER
"

OPREFIX=$PREFIX
PREFIX+=/llvm-$MAJVER

PKGDIFFPATH="${PREFIX#/}/lib/$PROG"
PKGDIFF_HELPER="
    s:$PKGDIFFPATH/[0-9][0-9.]*:$PKGDIFFPATH/VERSION:
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=llvm-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
    -DVERSION=$MAJVER
"

CONFIGURE_OPTS[amd64]=
CONFIGURE_OPTS[amd64_WS]="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=\"$PREFIX\"
    -DCMAKE_C_COMPILER=\"$CC\"
    -DCMAKE_CXX_COMPILER=\"$CXX\"
    -DCMAKE_C_LINK_FLAGS=\"${LDFLAGS[amd64]}\"
    -DCMAKE_CXX_LINK_FLAGS=\"${LDFLAGS[amd64]}\"
    -DGCC_INSTALL_PREFIX=\"$GCCPATH\"
    -DCLANG_VENDOR=\"$DISTRO/$RELVER\"
    -DCLANG_DEFAULT_RTLIB=libgcc
    -DCLANG_DEFAULT_CXX_STDLIB=libstdc++
    -DLLVM_DIR=\"$PREFIX/lib/cmake/llvm\"
    -DLLVM_INCLUDE_TESTS=OFF
"
LDFLAGS+=" -lm"
# we want to end up with '$ORIGIN/../lib' as runpath and not with
# '$PREFIX/lib:$ORIGIN/../lib'; yet we need to find libLLVM during build time
export LD_LIBRARY_PATH="$PREFIX/lib"

init
download_source llvm llvm-project $VER.src
patch_source
prep_build cmake+ninja
build -noctf    # C++
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
