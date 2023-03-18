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
CONFIGURE_OPTS[i386]="
    --bindir=$PREFIX/bin/i386
    --sbindir=$PREFIX/sbin/i386
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/amd64
"
[ $RELVER -ge 151037 ] && LDFLAGS[i386]+=" -lssp_ns"

save_function make_install _make_install
make_install() {
    _make_install
    logcmd mkdir -p $DESTDIR/usr/lib/fs/$PROG || logerr "mkdir failed"
    logcmd cp $SRCDIR/files/fstyp $DESTDIR/usr/lib/fs/$PROG \
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
