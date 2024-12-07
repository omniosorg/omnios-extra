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

PROG=swtpm
VER=0.10.0
PKG=ooce/security/swtpm
SUMMARY="SWTPM - Software TPM Emulator"
DESC="TPM emulators with different front-end interfaces to libtpms"

JSONGLIBVER=1.9.2

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64
set_clangver
set_standard XPG6

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

init
prep_build

#########################################################################
# Download and build static versions of dependencies

pre_configure() {
    typeset arch=$1

    ! cross_arch $arch && return

    CONFIGURE_CMD+=" --cross-file $SRCDIR/files/aarch64-gcc.txt"
}

save_buildenv

CONFIGURE_OPTS="-Ddefault_library=static"
CONFIGURE_OPTS[aarch64]="
    --prefix=$PREFIX
    --libdir=$PREFIX/${LIBDIRS[aarch64]}
"

build_dependency -meson json-glib json-glib-$JSONGLIBVER \
    $PROG/json-glib json-glib $JSONGLIBVER

restore_buildenv

#########################################################################

note -n "-- Building $PROG"

CONFIGURE_OPTS="
    --localstatedir=/var$PREFIX
    --disable-static
    --with-tss-user=root
    --with-tss-group=root
"

pre_configure() {
    typeset arch=$1

    subsume_arch $arch PKG_CONFIG_PATH
    addpath PKG_CONFIG_PATH $DEPROOT$PREFIX/${LIBDIRS[$arch]}/pkgconfig

    CPPFLAGS+=" -DHAVE_SYS_IOCCOM_H -I$DEPROOT$PREFIX/include/json-glib-1.0"
    LDFLAGS[$arch]+=" -L$DEPROOT$PREFIX/${LIBDIRS[$arch]} -lsocket"
    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}/$PROG"

    run_autoreconf -fi
}

download_source $PROG v$VER
patch_source
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
