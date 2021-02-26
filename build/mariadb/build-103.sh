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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=mariadb
VER=10.3.28
PKG=ooce/database/mariadb-103
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
    compress/lz4
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
    -DUSER=mysql -DGROUP=mysql
"

set_arch 64

CFLAGS64+=" -O3 -I$OPREFIX/include -I/usr/include/gssapi"
CXXFLAGS64="$CFLAGS64 -R$OPREFIX/lib/$ISAPART64"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

CONFIGURE_OPTS_64=
CONFIGURE_OPTS_WS_64="
    -DCOMPILATION_COMMENT=\"OmniOSce MariaDB Server\"

    -DCMAKE_VERBOSE_MAKEFILE=1
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_FLAGS_RELEASE=\"$CFLAGS64\"
    -DCMAKE_CXX_FLAGS_RELEASE=\"$CXXFLAGS64\"
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DCMAKE_MODULE_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=\"$LDFLAGS64\"
    -DWITH_MYSQLD_LDFLAGS=-lumem

    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DDEFAULT_SYSCONFDIR=$CONFPATH
    -DMYSQL_DATADIR=$VARPATH/data

    -DINSTALL_LAYOUT=STANDALONE
    -DINSTALL_LIBDIR=lib/$ISAPART64
    -DINSTALL_UNIX_ADDRDIR=/tmp/mysql-$MAJVER.sock
    -DMYSQL_MAINTAINER_MODE=OFF
    -DWITH_DEBUG=OFF
    -DENABLE_DEBUG_SYNC=OFF

    -DENABLE_DTRACE=OFF
    -DWITH_READLINE=ON
    -DWITH_EMBEDDED_SERVER=OFF
    -DWITHOUT_MROONGA_STORAGE_ENGINE=ON
    -DPLUGIN_CONNECT=NO

    -DENABLED_LOCAL_INFILE=1
    -DWITH_EXTRA_CHARSETS=complex

    -DWITH_SSL=yes
    -DWITH_ZLIB=bundled
    -DWITH_INNODB_LZ4=ON

    -DWITH_PIC=1
"

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake
build
strip_install
logcmd mkdir -p $DESTDIR/$CONFPATH
xform files/my.cnf > $DESTDIR/$CONFPATH/my.cnf
xform files/mariadb-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
xform files/mariadb-template > $TMPDIR/$PROG-$sMAJVER
install_smf -oocemethod ooce $PROG-$sMAJVER.xml $PROG-$sMAJVER
make_package server.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
