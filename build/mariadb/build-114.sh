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

PROG=mariadb
VER=11.4.4
PKG=ooce/database/mariadb-114
SUMMARY="MariaDB"
DESC="A community-developed, commercially supported fork of the "
DESC+="MySQL relational database management system"

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
set_patchdir patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$PREFIX
VARPATH=/var$PREFIX
RUNPATH=$VARPATH/run

SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1
NO_SONAME_EXPECTED=1

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

CPPFLAGS+=" -DOOCEVER=$RELVER"
CFLAGS+=" -O3 -I$OPREFIX/include -I/usr/include/gssapi"
CXXFLAGS[i386]="$CFLAGS ${CFLAGS[i386]} -R$OPREFIX/lib"
CXXFLAGS[amd64]="$CFLAGS ${CFLAGS[amd64]} -R$OPREFIX/lib/amd64"
LDFLAGS[i386]+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"

CONFIGURE_OPTS=
CONFIGURE_OPTS[i386]=
CONFIGURE_OPTS[amd64]=
CONFIGURE_OPTS[i386_WS]="
    -DFEATURE_SET=xsmall
    -DCMAKE_C_FLAGS_RELEASE=\"$CFLAGS ${CFLAGS[i386]}\"
    -DCMAKE_CXX_FLAGS_RELEASE=\"${CXXFLAGS[i386]}\"
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE=\"${LDFLAGS[i386]}\"
    -DCMAKE_MODULE_LINKER_FLAGS_RELEASE=\"${LDFLAGS[i386]}\"
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=\"${LDFLAGS[i386]}\"
    -DINSTALL_BINDIR=bin/i386
    -DINSTALL_SBINDIR=bin/i386
    -DINSTALL_SCRIPTDIR=bin/i386
    -DINSTALL_LIBDIR=lib
    -DWITH_MARIABACKUP=OFF
    -DWITH_UNIT_TESTS=OFF
"
CONFIGURE_OPTS[amd64_WS]="
    -DFEATURE_SET=community
    -DCMAKE_C_FLAGS_RELEASE=\"$CFLAGS ${CFLAGS[amd64]}\"
    -DCMAKE_CXX_FLAGS_RELEASE=\"${CXXFLAGS[amd64]}\"
    -DCMAKE_EXE_LINKER_FLAGS_RELEASE=\"${LDFLAGS[amd64]}\"
    -DCMAKE_MODULE_LINKER_FLAGS_RELEASE=\"${LDFLAGS[amd64]}\"
    -DCMAKE_SHARED_LINKER_FLAGS_RELEASE=\"${LDFLAGS[amd64]}\"
    -DINSTALL_BINDIR=bin
    -DINSTALL_SBINDIR=bin
    -DINSTALL_SCRIPTDIR=bin
    -DINSTALL_LIBDIR=lib/amd64
"
CONFIGURE_OPTS[WS]="
    -DWITH_COMMENT=\"$DISTRO MariaDB Server\"
    -DCOMPILATION_COMMENT=\"$DISTRO MariaDB Server\"

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

    -DENABLE_DTRACE=OFF
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

# Make ISA binaries for mysql_config, to allow software to find the
# right settings for 32/64-bit when pkg-config is not used.
make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p amd64
    logcmd mv *_config amd64/ || logerr "mv mysql_config"
    make_isaexec_stub_arch amd64 $PREFIX/bin
    popd >/dev/null
}

build_manifests() {
    manifest_start $TMPDIR/manifest.client
    manifest_add_dir $PREFIX/include mysql
    manifest_add_dir $PREFIX/lib pkgconfig amd64 amd64/pkgconfig
    manifest_add $PREFIX/bin '.*(mysql|mariadb)_config' mysql mariadb
    manifest_add $PREFIX/man/man1 mariadb.1 mysql.1 '(mysql|mariadb)_config.1'
    manifest_finalise $TMPDIR/manifest.client $OPREFIX

    manifest_uniq $TMPDIR/manifest.{server,client}
    manifest_finalise $TMPDIR/manifest.server $OPREFIX etc
}

init
download_source $PROG $PROG $VER
patch_source
prep_build cmake+ninja
build
strip_install
make_isa_stub
add_notes README.install
logcmd mkdir -p $DESTDIR/$CONFPATH
xform files/my.cnf > $DESTDIR/$CONFPATH/my.cnf
xform files/mariadb-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
xform files/mariadb-template > $TMPDIR/$PROG-$sMAJVER
install_smf -oocemethod ooce $PROG-$sMAJVER.xml $PROG-$sMAJVER
build_manifests
PKG=${PKG/database/library} SUMMARY+=" client and libraries" \
    make_package -seed $TMPDIR/manifest.client
RUN_DEPENDS_IPS="${PKG/database/library} ooce/database/mariadb-common" \
    make_package -seed $TMPDIR/manifest.server server.mog
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
