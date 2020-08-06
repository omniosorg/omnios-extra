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

PROG=php
PKG=ooce/application/php-73
VER=7.3.21
SUMMARY="PHP 7.3"
DESC="A popular general-purpose scripting language"

set_arch 64

SKIP_LICENCES=PHP

# configure needs gawk for 7.3.6 as awk bails out with
# record .... too long
export AWK

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$OPREFIX/$PROG
VARPATH=/var$OPREFIX/$PROG
RUNPATH=$VARPATH/run

BUILD_DEPENDS_IPS="
    ooce/database/bdb
    ooce/database/lmdb
    ooce/library/freetype2
    ooce/library/libjpeg-turbo
    ooce/library/libpng
"
RUN_DEPENDS_IPS="ooce/application/php-common"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=$CONFPATH
    --localstatedir=$VARPATH
    --with-config-file-path=$CONFPATH/php.ini

    --disable-libgcc
    --with-iconv
    --enable-dtrace
    --enable-ftp
    --enable-mbstring
    --enable-calendar
    --enable-dba
    --enable-soap
    --enable-libxml
    --with-gettext
    --enable-pcntl
    --with-openssl
    --with-gmp
    --with-mysqli=mysqlnd
    --with-pdo-mysql=mysqlnd
    --with-zlib=/usr
    --with-zlib-dir=/usr
    --with-bz2=/usr
    --with-curl
    --with-gd

    --with-db4=$OPREFIX
    --with-lmdb=$OPREFIX
    --with-jpeg-dir=$OPREFIX
    --with-png-dir=$OPREFIX
    --with-freetype-dir=$SRCDIR/files

    --enable-fpm
    --with-fpm-user=php
    --with-fpm-group=php
"

CPPFLAGS+=" -I/usr/include/gmp"
LDFLAGS+=" -static-libgcc -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

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

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
xform files/php-template.xml > $TMPDIR/$PROG-$sMAJVER.xml
xform files/php-template > $TMPDIR/$PROG-$sMAJVER
install_smf application $PROG-$sMAJVER.xml $PROG-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
