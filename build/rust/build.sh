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

. ../../lib/arch.sh
. ../../lib/build.sh

PROG=rust
PKG=ooce/developer/rust
VER=1.84.0
SUMMARY="Rust systems programming language"
DESC="Rust is a systems programming language that runs blazingly fast, "
DESC+="prevents segfaults, and guarantees thread safety."

set_builddir ${PROG}c-${VER}-src

OPREFIX=$PREFIX
PREFIX+=/$PROG

BUILD_DEPENDS_IPS="developer/gnu-binutils"
# `rustc` uses `gcc` as its linker. Other dependencies such as the C runtime
# and linker are themselves pulled in as dependencies of the gcc package.
RUN_DEPENDS_IPS="developer/gcc$GCCVER"

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

CONFIGURE_OPTS[$BUILD_ARCH]="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --localstatedir=/var$PREFIX
"
CONFIGURE_OPTS+="
    --release-description=OmniOS/$RELVER
    --enable-vendor
    --enable-local-rust
    --enable-extended
    --build=${RUSTTRIPLETS[$BUILD_ARCH]}
    --set target.${RUSTTRIPLETS[$BUILD_ARCH]}.cc=$CC
    --set target.${RUSTTRIPLETS[$BUILD_ARCH]}.cxx=$CXX
    --set target.${RUSTTRIPLETS[$BUILD_ARCH]}.ar=$USRBIN/ar
    --enable-rpath
    --enable-ninja
    --disable-codegen-tests
    --disable-dist-src
    --disable-llvm-static-stdcpp
    --disable-docs
    --release-channel=stable
    --python=$PYTHON
"

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

pre_configure() {
    target="${RUSTTRIPLETS[$BUILD_ARCH]}"

    for a in $CROSS_ARCH; do
        # we need the sysroot to build target support
        init_sysroot $a ${PKGSRVR%%/}.$a

        target+=",${RUSTTRIPLETS[$a]}"

        archprefix=$CROSSTOOLS/$a/bin/${TRIPLETS[$a]}
        CONFIGURE_OPTS[$BUILD_ARCH]+="
            --set target.${RUSTTRIPLETS[$a]}.cc=$archprefix-gcc
            --set target.${RUSTTRIPLETS[$a]}.cxx=$archprefix-g++
            --set target.${RUSTTRIPLETS[$a]}.ar=$archprefix-ar
        "
        tripus=${RUSTTRIPLETS[aarch64]//-/_}
        tripuc=${tripus^^}
        export CARGO_TARGET_${tripuc}_RUSTFLAGS="
            -C link-arg=--sysroot=${SYSROOT[$a]}
        "
    done

    CONFIGURE_OPTS+=" --target=$target"
}

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
