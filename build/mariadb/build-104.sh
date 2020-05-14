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

PROG=mariadb
VER=10.4.13
PKG=ooce/database/mariadb-104
SUMMARY="MariaDB"
DESC="A community-developed, commercially supported fork of the "
DESC+="MySQL relational database management system"

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$PREFIX
VARPATH=/var$PREFIX
RUNPATH=$VARPATH/run

BUILD_DEPENDS_IPS="
    ooce/developer/cmake
    ooce/compress/lz4
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

CFLAGS+=" -O3 -I$OPREFIX/include -I/usr/include/gssapi"
CXXFLAGS32="$CFLAGS $CFLAGS32 -R$OPREFIX/lib"
CXXFLAGS64="$CFLAGS $CFLAGS64 -R$OPREFIX/lib/$ISAPART64"
LDFLAGS32+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
# Prevents "Text relocation remains referenced against symbol offset
# in file ../../sql/mysqld_dtrace_all.o" error
LDFLAGS+=" -Bsymbolic -mimpure-text -lrt"

CONFIGURE_OPTS=
CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64=
CONFIGURE_OPTS_WS_32="
    -DFEATURE_SET=xsmall
    -DCMAKE_C_FLAGS_RELEASE=\"$CFLAGS $CFLAGS32\"
    -DCMAKE_CXX_FLAGS_RELEASE=\"$CXXFLAGS32\"
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE=\"$LDFLAGS32\"
    -DCMAKE_MODULE_LINKER_FLAGS_RELEASE=\"$LDFLAGS32\"
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=\"$LDFLAGS32\"
    -DINSTALL_BINDIR=$PREFIX/bin/$ISAPART
    -DINSTALL_SBINDIR=$PREFIX/bin/$ISAPART
    -DINSTALL_SCRIPTDIR=$PREFIX/bin/$ISAPART
    -DINSTALL_LIBDIR=lib
    -DWITH_MARIABACKUP=OFF
    -DWITH_UNIT_TESTS=OFF
"
CONFIGURE_OPTS_WS_64="
    -DFEATURE_SET=community
    -DCMAKE_C_FLAGS_RELEASE=\"$CFLAGS $CFLAGS64\"
    -DCMAKE_CXX_FLAGS_RELEASE=\"$CXXFLAGS64\"
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DCMAKE_MODULE_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DINSTALL_BINDIR=$PREFIX/bin
    -DINSTALL_SBINDIR=$PREFIX/bin
    -DINSTALL_SCRIPTDIR=$PREFIX/bin
    -DINSTALL_LIBDIR=lib/$ISAPART64
"
CONFIGURE_OPTS_WS="
    -DWITH_COMMENT=\"OmniOS MariaDB Server\"
    -DCOMPILATION_COMMENT=\"OmniOS MariaDB Server\"

    -DCMAKE_VERBOSE_MAKEFILE=1
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_REQUIRED_INCLUDES=/usr/include/pcre

    -DINSTALL_LAYOUT=SVR4
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DDEFAULT_SYSCONFDIR=$CONFPATH
    -DMYSQL_DATADIR=$VARPATH/data
    -DINSTALL_UNIX_ADDRDIR=/tmp/mysql-$MAJVER.sock

    -DWITH_SSL=yes
    -DWITH_ZLIB=system
    -DWITH_PCRE=system
    -DWITH_SSL=system

    -DMYSQL_MAINTAINER_MODE=OFF
    -DWITH_DEBUG=OFF
    -DENABLE_DEBUG_SYNC=OFF

    -DENABLE_DTRACE=ON
    -DWITH_READLINE=ON
    -DWITH_EMBEDDED_SERVER=OFF
    -DWITHOUT_MROONGA_STORAGE_ENGINE=ON
    -DPLUGIN_AUTH_SOCKET=YES
    -DPLUGIN_CONNECT=NO

    -DENABLED_LOCAL_INFILE=1
    -DWITH_EXTRA_CHARSETS=complex

    -DWITH_INNODB_LZ4=ON
    -DWITH_MYSQLD_LDFLAGS=-lumem

    -DWITH_PIC=1
"

save_function make_install _make_install
make_install() {
    _make_install
    logcmd mkdir -p $DESTDIR/$CONFPATH
    sed < $SRCDIR/files/my.cnf > $DESTDIR/$CONFPATH/my.cnf "
        s/%MAJVER%/$MAJVER/g
        s/%sMAJVER%/$sMAJVER/g
    "
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake
build
strip_install
add_notes README.install
install_smf application $PROG-$sMAJVER.xml $PROG-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
