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

PROG=icu4c
VER=76.1
PKG=ooce/library/icu4c
SUMMARY="ICU - International Components for Unicode"
DESC="A mature, widely used set of C/C++ libraries providing "
DESC+="Unicode and Globalization support for software applications"

set_builddir icu/source

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="--disable-samples"
CONFIGURE_OPTS[amd64]+="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
"

CXXFLAGS[aarch64]+=" -mtls-dialect=trad"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    save_variable BUILDARCH
    save_buildenv
    set_arch $BUILD_ARCH
    set_gccver $DEFAULT_GCC_VER

    save_builddir __native_tools__
    append_builddir "_native_tools"
    logcmd $MKDIR -p $TMPDIR/$BUILDDIR || logerr "mkdir failed"
    CONFIGURE_CMD=../configure

    note -n "-- Building native tools"

    # not installing the native tools
    pre_install() { false; }

    build

    set_crossgcc $arch
    restore_builddir __native_tools__
    restore_buildenv
    restore_variable BUILDARCH

    unset -f pre_install

    CONFIGURE_OPTS[$arch]+="
        --with-cross-build=$TMPDIR/$BUILDDIR/_native_tools
    "

    note -n "-- Building $PROG"
}

post_install() {
    [ "$1" != amd64 ] && return

    # Make ISA binaries for icu-config, to allow software to find the
    # right settings for 32/64-bit when pkg-config is not used.
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd $MKDIR -p amd64
    logcmd $MV icu-config amd64/ || logerr "mv icu-config"
    make_isaexec_stub_arch amd64 $PREFIX/bin
    popd >/dev/null
}

init
download_source $PROG $PROG-${VER//./_}-src
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
