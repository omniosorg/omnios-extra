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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=ntfs-3g
VER=2017.3.23AR.5
PKG=ooce/system/file-system/ntfs-3g
SUMMARY="${PROG^^} - Read-Write NTFS Driver"
DESC="A stable, full-featured, read-write NTFS driver for Linux, Android, "
DESC+="Mac OS X, FreeBSD, NetBSD, OpenSolaris, QNX, Haiku, "
DESC+="and other operating systems"

set_builddir ${PROG}_ntfsprogs-$VER

OPREFIX=$PREFIX
PREFIX+="/$PROG"

RUN_DEPENDS_IPS="ooce/driver/fuse"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --exec-prefix=$PREFIX
    --includedir=$OPREFIX/include
"
CONFIGURE_OPTS_32="
    --bindir=$PREFIX/bin/$ISAPART
    --sbindir=$PREFIX/sbin/$ISAPART
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS_64="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
    --libdir=$OPREFIX/lib/$ISAPART64
"

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
