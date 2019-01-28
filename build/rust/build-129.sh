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

# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
. ../../lib/functions.sh

PROG=rust
PKG=ooce/developer/rust
VER=1.29.2
SUMMARY="Rust systems programming language"
DESC="Rust is a systems programming language that runs blazingly fast, "
DESC+="prevents segfaults, and guarantees thread safety."

BOOTSTRAP_VER=1.28.0

BUILD_DEPENDS_IPS+="
    developer/gnu-binutils
    runtime/python-35
"

BUILDARCH=64

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$OPREFIX/$PROG
VARPATH=/var$OPREFIX/$PROG
RUNPATH=$VARPATH/run

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

export RUSTARCH=x86_64-sun-solaris
export RUSTFLAGS="-C linker=$CC"
export RUST_BACKTRACE=1
export PATH+=":$OPREFIX/bin"
export GNUAR=/bin/gar

# Required to enable the POSIX 1003.6 style getpwuid_r() prototype
CFLAGS+=" -D_POSIX_PTHREAD_SEMANTICS"
CXXFLAGS+=" -D_POSIX_PTHREAD_SEMANTICS"
export CFLAGS CXXFLAGS

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
"

CONFIGURE_OPTS+="
    --enable-vendor
    --enable-extended
    --disable-jemalloc
    --default-linker=$CC
    --set rust.default-linker=$CC
    --set target.$RUSTARCH.cc=$CC
    --set target.$RUSTARCH.cxx=$CXX
    --set target.$RUSTARCH.ar=$GNUAR
    --set target.$RUSTARCH.linker=$CC
    --enable-rpath
    --disable-codegen-tests
    --disable-dist-src
    --disable-llvm-static-stdcpp
    --disable-ninja
    --disable-docs
    --release-channel=stable
    --python=/usr/bin/python3
"

save_function make_install _make_install
make_install() {
    mkdir -p $DESTDIR/$PREFIX
    _make_install "$@"
}

fix_runpaths() {
    pushd $DESTDIR/$PREFIX >/dev/null

    rpath="$PREFIX/lib:/usr/lib/64:/usr/gcc/$DEFAULT_GCC_VER/lib/amd64"
    for f in bin/{cargo,clippy-driver,rustc,rustdoc} lib/*.so; do
        logcmd elfedit -e "dyn:value -s RUNPATH $rpath" $f
        logcmd elfedit -e "dyn:value -s RPATH $rpath" $f
    done

    popd >/dev/null
}

init

# Download and extract the bootstrap binary package
STRAPVER=$BOOTSTRAP_VER-$RUSTARCH
BUILDDIR=$PROG-$STRAPVER
download_source $PROG $PROG $STRAPVER
BOOTSTRAP_PATH=$TMPDIR/$BUILDDIR
CONFIGURE_OPTS+=" --local-rust-root=$BOOTSTRAP_PATH "
export RUSTC=$BOOTSTRAP_PATH/bin/rustc

# Download the rust source code
BUILDDIR=${PROG}c-${VER}-src
PATCHDIR=patches-$sMAJVER
download_source $PROG ${PROG}c $VER-src

patch_source
prep_build
build
fix_runpaths
make_package
#clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
