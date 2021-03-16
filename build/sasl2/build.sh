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

SKIP_RTIME_CHECK=1
SKIP_LICENCES='*'

# Sasl runs make recursively and does not honour $MAKE - put GNU first
# in the path.
PATH=$GNUBIN:$PATH

# configure runs mysql_config/pg_config to determine the proper paths
# for the database libraries. To avoid having to rely on a particular
# mediator value for the installed packages, set the explicitly versioned
# bin directories first in the PATH.
PATH=$PREFIX/mariadb-$MARIASQLVER/bin:$PREFIX/pgsql-$PGSQLVER/bin:$PATH

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
    --enable-ldapdb \
    --with-ldap
    --with-mysql=$PREFIX/mariadb-$MARIASQLVER
    --with-pgsql=$PREFIX/pgsql-$PGSQLVER
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
    [ `grep -c 'lpq... yes' $SRCDIR/build.log` = 2 ] \
        || logerr "$PROG was not built with postgres"
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
