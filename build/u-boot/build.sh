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

PROG=u-boot
PKG=ooce/util/u-boot
VER=2024.01
SUMMARY="Das U-Boot"
DESC="$SUMMARY: Universal Bootloader"

set_arch 64

MAKE_TARGET="sandbox_defconfig tools"

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        V=1
        HOSTCC=\"$CC\"
        HOSTCFLAGS=\"$CFLAGS ${CFLAGS[$arch]} -I$PREFIX/include\"
        HOSTLDLIBS=\"
            $LDFLAGS ${LDFLAGS[$arch]}
            -L$PREFIX/${LIBDIRS[$arch]} -lnsl -lsocket
        \"
    "

    # no configure
    false
}

make_install() {
    typeset dst=$DESTDIR$PREFIX/$PROG

    set -eE; trap 'logerr Installation failed at $BASH_LINENO' ERR

    # For now, this is all that's shipped in this package, which is the single
    # tool needed to build the arm64-gate. It will be extended as required.
    logcmd $MKDIR -p $dst/tools
    logcmd $CP tools/mkimage $dst/tools/

    set +eE; trap - ERR
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
