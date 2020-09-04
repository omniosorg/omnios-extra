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

PROG=cyrus-sasl
VER=2.1.27
PKG=ooce/library/security/libsasl2
SUMMARY="Simple Authentication and Security Layer (SASL)"
DESC="$SUMMARY shared library and plugins"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

set_standard XPG6

SKIP_RTIME=1
SKIP_LICENCES='*'

# Sasl runs make recursively and does not honour $MAKE - put GNU first
# in the path.
PATH=$GNUBIN:$PATH

# configure runs mysql_config to determine the proper library path for
# mariadb. Set the correct mariadb version path first so that it will find
# the isaexec mysql_config which will return the correct paths depending on
# 32/64-bit build.
PATH=$PREFIX/mariadb-$MARIASQLVER/bin:$PATH

# NB: pgsql is currently only shipped 64-bit so cannot be used here
#    --with-pgsql=$PREFIX/pgsql-$PGSQLVER

ETCDIR=/etc$PREFIX/sasl2
VARDIR=/var$PREFIX/sasl2

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=$ETCDIR
    --with-configdir=$ETCDIR
    --with-saslauthd=/var/run/saslauthd
    --with-ipctype=doors

    --enable-plain
    --enable-login
    --enable-sql
    --with-mysql=$PREFIX/mariadb-$MARIASQLVER
    --without-pgsql
    --with-gss_impl=mit

    --enable-auth-sasldb
    --with-dblib=lmdb
    --with-dbpath=$VARDIR/sasldb2
"

CONFIGURE_OPTS_32+="
    --with-plugindir=$PREFIX/lib/sasl2
"

CONFIGURE_OPTS_64+="
    --with-plugindir=$PREFIX/lib/$ISAPART64/sasl2
    --sbindir=$PREFIX/sbin
"

# To find lmdb
CPPFLAGS+=" -I$PREFIX/include"
LDFLAGS32+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS64+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

tests() {
    [ `grep -c 'checking DB library to use... lmdb' $SRCDIR/build.log` = 4 ] \
        || logerr "$PROG was not built with lmdb"
    [ `grep -c 'lmysqlclient... yes' $SRCDIR/build.log` = 2 ] \
        || logerr "$PROG was not built with mariadb"
}

init
download_source cyrus $PROG $VER
prep_build
patch_source
run_autoreconf -fi
# Remove the pre-rendered version of the man page to force a new one.
logcmd rm $TMPDIR/$BUILDDIR/saslauthd/saslauthd.8
build -ctf
tests
xform files/saslauthd.xml > $TMPDIR/saslauthd.xml
install_smf ooce saslauthd.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
