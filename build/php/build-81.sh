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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=php
PKG=ooce/application/php-81
VER=8.1.17
SUMMARY="PHP 8.1"
DESC="A popular general-purpose scripting language"

PANDAHASH=3452f15

set_arch 64

SKIP_LICENCES=PHP

# configure needs gawk for 7.3.6 as awk bails out with
# record .... too long
export AWK

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
set_patchdir patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
VARPATH=/var$PREFIX
RUNPATH=/var$OPREFIX/$PROG/run

# The icu4c ABI changes frequently. Lock the version
# pulled into each build of php.
ICUVER=`pkg_ver icu4c`
ICUVER=${ICUVER%%.*}
BUILD_DEPENDS_IPS="
    =ooce/library/icu4c@$ICUVER
    ooce/database/bdb
    ooce/database/lmdb
    ooce/library/icu4c
    ooce/library/libgd
    ooce/library/libzip
    ooce/library/onig
"
RUN_DEPENDS_IPS="
    =ooce/library/icu4c@$ICUVER
    ooce/application/php-common
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

init
prep_build

######################################################################
# Build dependencies

save_buildenv
save_function make_install _make_install

make_install() {
    logcmd mkdir -p $DESTDIR/lib $DESTDIR/include
    logcmd cp c-client/c-client.a $DESTDIR/lib/libc-client.a \
        || logerr "Installation of libc-client.a failed"
    logcmd cp c-client/*.h $DESTDIR/include/ \
        || logerr "Installation of c-client headers failed"
}

CONFIGURE_CMD=/bin/true \
    NO_PARALLEL_MAKE=1 \
    MAKE_TARGET=gso \
    MAKE_ARGS="SSLLIB=/usr/lib/64 SSLTYPE=unix" \
    MAKE_ARGS_WS="
        EXTRACFLAGS=\"-I$OPENSSLPATH/include/openssl $CFLAGS ${CFLAGS[amd64]}\"
    " \
    build_dependency uw-imap panda-imap-master uw-imap panda-imap $PANDAHASH

save_function _make_install make_install
restore_buildenv

note -n "Building $PROG $VER"

######################################################################

CONFIGURE_OPTS[amd64]="
    --prefix=$PREFIX
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --with-config-file-path=$CONFPATH

    --disable-libgcc
    --with-iconv
    --enable-intl
    --enable-dtrace
    --enable-ftp
    --enable-mbstring
    --enable-calendar
    --enable-dba
    --enable-soap
    --with-gettext
    --enable-pcntl
    --with-openssl
    --with-gmp
    --with-mysqli=mysqlnd
    --with-pdo-mysql=mysqlnd
    --with-zlib=/usr
    --with-zlib-dir=/usr
    --with-bz2=/usr
    --with-readline=/usr
    --with-curl
    --enable-gd
    --with-jpeg
    --with-freetype
    --enable-sockets
    --enable-bcmath
    --enable-exif
    --with-zip
    --with-imap=$DEPROOT
    --with-imap-ssl=/usr

    --with-db4=$OPREFIX
    --with-lmdb=$OPREFIX
    --with-ldap=$OPREFIX
    --with-pgsql=$OPREFIX/pgsql-$PGSQLVER
    --with-pdo-pgsql=$OPREFIX/pgsql-$PGSQLVER

    --enable-fpm
    --with-fpm-user=php
    --with-fpm-group=php
"

# opcache-jit does not build on r151030
[ $RELVER -lt 151036 ] && CONFIGURE_OPTS[amd64]+=" --disable-opcache-jit"

CPPFLAGS+=" -I/usr/include/gmp"
CPPFLAGS+=" -I$OPREFIX/libzip/include"
LDFLAGS+=" -static-libgcc -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"

save_function configure64 _configure64
function configure64() {
    _configure64 "$@"
    for tok in \
        HAVE_CURL HAVE_IMAP HAVE_LDAP \
        HAVE_GD_BMP HAVE_GD_FREETYPE HAVE_GD_JPG HAVE_GD_PNG \
        MYSQLI_USE_MYSQLND PDO_USE_MYSQLND \
        HAVE_PDO_PGSQL HAVE_PGSQL \
    ; do
        $EGREP -s "define $tok 1" $TMPDIR/$BUILDDIR/main/php_config.h \
            || logerr "Feature $tok is not enabled"
    done
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE INSTALL_ROOT=${DESTDIR} install || \
        logerr "--- Make install failed"

    pushd $DESTDIR/$CONFPATH >/dev/null

    # Enable PID file by default
    sed < php-fpm.conf.default > php-fpm.conf "
            /^;pid =/ {
                s/;//
                s/php-fpm/php-$MAJVER-fpm/
            }
    "
    # Provide working configuration out of the box
    sed < php-fpm.d/www.conf.default > php-fpm.d/www.conf "
        /^listen / {
            s/^/;/
            a\\
listen = $RUNPATH/www-$MAJVER.sock
        }
        /listen.mode/ {
            s/^;//
            s/0660/0664/
        }
    "

    # Provide production php.ini
    sed < $TMPDIR/$BUILDDIR/php.ini-production > php.ini '
        /^;*cgi\.fix_pathinfo=1/c\
cgi.fix_pathinfo=0
        /^expose_php =/c\
expose_php = Off
        /^;*upload_tmp_dir =/c\
upload_tmp_dir = /tmp
    '

    popd >/dev/null
}

download_source $PROG $PROG $VER
patch_source
build
strip_install
xform files/php-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
xform files/php-template > $TMPDIR/$PROG-$sMAJVER
install_smf application $PROG-$sMAJVER.xml $PROG-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
