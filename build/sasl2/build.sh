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

PROG=cyrus-sasl
VER=2.1.28
PKG=ooce/library/security/libsasl2
SUMMARY="Simple Authentication and Security Layer (SASL)"
DESC="$SUMMARY shared library and plugins"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

forgo_isaexec
set_standard XPG6

SKIP_RTIME_CHECK=1
SKIP_LICENCES='*'

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
    --with-gss_impl=mit

    --enable-auth-sasldb
    --with-dblib=lmdb
    --with-dbpath=$VARDIR/sasldb2
"

buildcnt=0

pre_configure() {
    typeset arch=$1

    ((buildcnt++))

    # Sasl runs make recursively and does not honour $MAKE - put GNU first
    # in the path.
    PATH=$GNUBIN:$PATH

    CONFIGURE_OPTS[$arch]+="
        --with-plugindir=$PREFIX/${LIBDIRS[$arch]}/sasl2
        --with-mysql=${SYSROOT[$arch]}$PREFIX/mariadb-$MARIASQLVER
        --with-pgsql=${SYSROOT[$arch]}$PREFIX/pgsql-$PGSQLVER
    "

    for l in mariadb-$MARIASQLVER pgsql-$PGSQLVER; do
        addpath PKG_CONFIG_PATH[$arch] \
            ${SYSROOT[$arch]}$PREFIX/$l/${LIBDIRS[$arch]}/pkgconfig
    done

    # To find lmdb
    CPPFLAGS+=" -I${SYSROOT[$arch]}$PREFIX/include"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    export CC_FOR_BUILD=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc
}

post_install() {
    typeset arch=$1

    pushd $DESTDIR/$PREFIX >/dev/null

    # We set the library runtime path explicitly for the shared
    # library that uses mariadb/postgres libraries instead of
    # just adding it to all shared libraries
    typeset rpath="$PREFIX/${LIBDIRS[$arch]}"
    rpath+=":$PREFIX/mariadb-$MARIASQLVER/${LIBDIRS[$arch]}"
    rpath+=":$PREFIX/pgsql-$PGSQLVER/${LIBDIRS[$arch]}"

    for f in `$FD -t f 'libsql\.so' ${LIBDIRS[$arch]}/sasl2/`; do
        logmsg "--- fixing runpath in $f"
        logcmd $ELFEDIT -e "dyn:value -s RUNPATH $rpath" $f
        logcmd $ELFEDIT -e "dyn:value -s RPATH $rpath" $f
    done

    popd >/dev/null

    [ $arch = i386 ] && return

    xform $SRCDIR/files/saslauthd.xml > $TMPDIR/saslauthd.xml
    install_smf ooce saslauthd.xml
}

tests() {
    c2=$buildcnt
    ((c2 *= 2))
    [ `grep -c 'checking DB library to use... lmdb' $SRCDIR/build.log` = $c2 ] \
        || logerr "$PROG was not built with lmdb"
    [ `grep -c 'lmysqlclient... yes' $SRCDIR/build.log` = $buildcnt ] \
        || logerr "$PROG was not built with mariadb"
    [ `grep -c 'lpq... yes' $SRCDIR/build.log` = $buildcnt ] \
        || logerr "$PROG was not built with postgres"
}

init
download_source cyrus $PROG $VER
prep_build
patch_source
run_autoreconf -fi
# Remove the pre-rendered version of the man page to force a new one.
logcmd $RM $TMPDIR/$BUILDDIR/saslauthd/saslauthd.8
build
tests
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
