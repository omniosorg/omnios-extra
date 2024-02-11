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

PROG=rust
PKG=ooce/developer/rust
VER=1.76.0
SUMMARY="Rust systems programming language"
DESC="Rust is a systems programming language that runs blazingly fast, "
DESC+="prevents segfaults, and guarantees thread safety."

# starting with release 1.69.0, rust requires at least llvm 14
LLVMVER=14

set_builddir ${PROG}c-${VER}-src

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="developer/gnu-binutils"
# `rustc` uses `gcc` as its linker. Other dependencies such as the C runtime
# and linker are themselves pulled in as dependencies of the gcc package.
RUN_DEPENDS_IPS="developer/gcc$GCCVER"

if test_relver '<' 151041; then
    SYSTEM_LLVM_PATH="/opt/ooce/llvm-$LLVMVER"
    RUN_DEPENDS_IPS="ooce/developer/llvm-$LLVMVER"
    BUILD_DEPENDS_IPS+=" $RUN_DEPENDS_IPS"

    ar=$USRBIN/gar
else
    ar=$USRBIN/ar
fi

# rust build requires the final install directory to be present
[ -d "$PREFIX" ] || logcmd $PFEXEC mkdir -p $PREFIX

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1
NO_SONAME_EXPECTED=1

RUSTARCH=x86_64-unknown-illumos

CONFIGURE_CMD="$PYTHON src/bootstrap/configure.py"

CONFIGURE_OPTS[amd64]="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
"

CONFIGURE_OPTS+="
    --release-description=OmniOS/$RELVER
    --enable-vendor
    --enable-local-rust
    --enable-extended
    --build=$RUSTARCH
    --target=$RUSTARCH
    --set target.$RUSTARCH.cc=$CC
    --set target.$RUSTARCH.cxx=$CXX
    --set target.$RUSTARCH.ar=$ar
    --enable-rpath
    --enable-ninja
    --disable-codegen-tests
    --disable-dist-src
    --disable-llvm-static-stdcpp
    --disable-docs
    --release-channel=stable
    --python=$PYTHON
"

if [ -n "$SYSTEM_LLVM_PATH" ]; then
    CONFIGURE_OPTS+="
        --enable-llvm-link-shared
        --llvm-config=$SYSTEM_LLVM_PATH/bin/llvm-config
    "
    llvm_lib="`$SYSTEM_LLVM_PATH/bin/llvm-config --libdir`"
    export RUSTFLAGS="-C link-arg=-L$llvm_lib -C link-arg=-R$llvm_lib"
fi

TESTSUITE_SED="
    /^$/ {
        N
        /failures:/b op
    }
    d
    :op
    /^gmake:/d
    /^Build completed/d
    n
    b op
"

pre_install() {
    logcmd $MKDIR -p $DESTDIR/$PREFIX || logerr "failed to create directory"
}

pre_test() {
    # https://github.com/rust-lang/rust/commit/13588cc681c9cc451ddf6286424b1a61
    # ^ has broken running the tests from a release tarball. Fix it by
    # re-creating the pre-requisites.
    logcmd $MKDIR -p .github/workflows
    logcmd $PYTHON x.py run src/tools/expand-yaml-anchors
}

init
download_source $PROG ${PROG}c $VER-src
patch_source
prep_build autoconf-like
build -noctf
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
