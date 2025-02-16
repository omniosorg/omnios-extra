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

PROG=ntfs-3g
VER=2022.10.3
PKG=ooce/system/file-system/ntfs-3g
SUMMARY="${PROG^^} - Read-Write NTFS Driver"
DESC="A stable, full-featured, read-write NTFS driver for Linux, Android, "
DESC+="Mac OS X, FreeBSD, NetBSD, OpenSolaris, QNX, Haiku, "
DESC+="and other operating systems"

set_builddir ${PROG}_ntfsprogs-$VER

OPREFIX=$PREFIX
PREFIX+="/$PROG"

forgo_isaexec

RUN_DEPENDS_IPS="ooce/driver/fuse"

SKIP_RTIME_CHECK=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --exec-prefix=$PREFIX
    --includedir=$OPREFIX/include
"
pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+="
        --libdir=$OPREFIX/${LIBDIRS[$arch]}
    "

    ! cross_arch $arch && return

    CONFIGURE_OPTS[$arch]+="
        HOST_CC=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc
    "
}

LDFLAGS[i386]+=" -lssp_ns"

post_install() {
    logcmd $MKDIR -p $DESTDIR/usr/lib/fs/$PROG || logerr "mkdir failed"
    logcmd $CP $SRCDIR/files/fstyp $DESTDIR/usr/lib/fs/$PROG \
        || logerr "cp fstyp failed"
}

init
download_source $PROG ${PROG}_ntfsprogs $VER
patch_source
prep_build
build
VER=${VER//AR/}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
