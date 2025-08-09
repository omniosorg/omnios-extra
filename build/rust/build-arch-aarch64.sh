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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=rust
PKG=ooce/developer/rust
VER=1.89.0
SUMMARY="Rust systems programming language"
DESC="Rust is a systems programming language that runs blazingly fast, "
DESC+="prevents segfaults, and guarantees thread safety."

set_builddir ${PROG}c-${VER}-src

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="developer/gnu-binutils"
# TODO: globbing only works reliably as long as we just have
# one cross compiler version per arch.
crossgccver=`pkg_ver aarch64/gcc*`
crossgccver=${crossgccver%%.*}
# `rustc` uses `gcc` as its linker. Other dependencies such as the C runtime
# and linker are themselves pulled in as dependencies of the gcc package.
RUN_DEPENDS_IPS="developer/gcc$crossgccver"

# rust build requires the final install directory to be present
[ -d "$PREFIX" ] || logcmd $PFEXEC mkdir -p $PREFIX

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1
NO_SONAME_EXPECTED=1

aarch64prefix=$CROSSTOOLS/aarch64/bin/${TRIPLETS[aarch64]}
CONFIGURE_OPTS[aarch64]="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
    --set target.${RUSTTRIPLETS[aarch64]}.cc=$aarch64prefix-gcc
    --set target.${RUSTTRIPLETS[aarch64]}.cxx=$aarch64prefix-g++
    --set target.${RUSTTRIPLETS[aarch64]}.ar=$aarch64prefix-ar
"
CONFIGURE_OPTS+="
    --release-description=OmniOS/$RELVER
    --enable-vendor
    --enable-local-rust
    --enable-extended
    --build=${RUSTTRIPLETS[$BUILD_ARCH]}
    --host=${RUSTTRIPLETS[aarch64]}
    --target=${RUSTTRIPLETS[aarch64]}
    --enable-rpath
    --enable-ninja
    --disable-codegen-tests
    --disable-dist-src
    --disable-llvm-static-stdcpp
    --disable-docs
    --release-channel=stable
    --python=$PYTHON
"

pre_configure() { :;
    # rust needs to find the native gcc for bootstrapping
    set_gccver $DEFAULT_GCC_VER

    tripus=${RUSTTRIPLETS[aarch64]//-/_}
    tripuc=${tripus^^}
    export CARGO_TARGET_${tripuc}_RUSTFLAGS="
        -C link-arg=--sysroot=${SYSROOT[aarch64]}
    "
    export CXXFLAGS_${tripus}="-mno-outline-atomics -mtls-dialect=trad"
}

pre_install() {
    logcmd $MKDIR -p $DESTDIR/$PREFIX || logerr "failed to create directory"
}

init
download_source $PROG ${PROG}c $VER-src
patch_source
prep_build autoconf-like
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
