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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pgbackrest
VER=2.60.0
PKG=ooce/database/pgbackrest
SUMMARY="pgBackRest"
DESC="Reliable backup and restore solution for PostgreSQL, supporting "
DESC+="full, differential and incremental backups, point-in-time recovery "
DESC+="and remote repositories over SSH/SFTP and object stores"

set_arch 64

OPREFIX=$PREFIX
PREFIX+="/$PROG"
CONFPATH="/etc$PREFIX"

# libpq from the default PostgreSQL version; the client protocol is
# compatible with all PostgreSQL versions supported by pgBackRest.
PGPREFIX=$OPREFIX/pgsql-$PGSQLVER

BUILD_DEPENDS_IPS="
    ooce/library/postgresql-$PGSQLVER
    ooce/library/libssh2
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        --prefix=$PREFIX
        -Dconfigdir=$CONFPATH
        -Dlibssh2=enabled
        -Dlibzstd=enabled
        -Dlibsystemd=disabled
    "

    addpath PKG_CONFIG_PATH[$arch] $PGPREFIX/${LIBDIRS[$arch]}/pkgconfig

    LDFLAGS[$arch]+=" -Wl,-R$OPREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -Wl,-R$PGPREFIX/${LIBDIRS[$arch]}"
}

post_install() {
    # The release tarball ships pre-built man pages which are not
    # installed by meson.
    typeset mandir=$TMPDIR/$EXTRACTED_SRC/doc/man
    [ -d "$mandir" ] || return

    for f in $mandir/*.[1-9]; do
        [ -f "$f" ] || continue
        typeset s=${f##*.}
        logcmd $MKDIR -p $DESTDIR$PREFIX/share/man/man$s || logerr "mkdir"
        logcmd $CP $f $DESTDIR$PREFIX/share/man/man$s/ \
            || logerr "Failed to install man page ${f##*/}"
    done
}

init
download_source $PROG $PROG $VER
patch_source
prep_build meson
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
