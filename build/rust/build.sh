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

PROG=rust
PKG=ooce/developer/rust
VER=1.58.1
SUMMARY="Rust systems programming language"
DESC="Rust is a systems programming language that runs blazingly fast, "
DESC+="prevents segfaults, and guarantees thread safety."

BUILDDIR=${PROG}c-${VER}-src

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="developer/gnu-binutils"

if [ $RELVER -lt 151041 ]; then
    [ $RELVER -ge 151036 ] && LLVM_MAJVER=13 || LLVM_MAJVER=12.0

    SYSTEM_LLVM_PATH="/opt/ooce/llvm-$LLVM_MAJVER"
    RUN_DEPENDS_IPS="ooce/developer/llvm-${LLVM_MAJVER//./}"
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

RUSTARCH=x86_64-unknown-illumos

CONFIGURE_CMD="$PYTHON src/bootstrap/configure.py"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
"

CONFIGURE_OPTS+="
    --enable-vendor
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

save_function make_install _make_install
make_install() {
    logcmd mkdir -p $DESTDIR/$PREFIX || logerr "failed to create directory"
    _make_install "$@"
}

init
download_source $PROG ${PROG}c $VER-src
patch_source
prep_build
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
