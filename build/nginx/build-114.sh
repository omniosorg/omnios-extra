#!/usr/bin/bash
#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright 2011-2013 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2019 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=nginx
PKG=ooce/server/nginx-114
VER=1.14.2
VERHUMAN=$VER
SUMMARY="nginx 1.14 web server"
DESC="nginx is a high-performance HTTP(S) server and reverse proxy"

BUILDARCH=64

SKIP_LICENCES=BSD

MAJVER=${VER%.*}            # M.m
sMAJVER=${MAJVER//./}       # Mm
PATCHDIR=patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$PREFIX
LOGPATH=/var/log$OPREFIX/$PROG
VARPATH=/var$OPREFIX/$PROG
RUNPATH=$VARPATH/run

BUILD_DEPENDS_IPS="library/security/openssl library/pcre"
RUN_DEPENDS_IPS="ooce/server/nginx-common"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

CONFIGURE_OPTS_64=" \
    --with-ipv6 \
    --with-threads \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_addition_module  \
    --with-http_xslt_module \
    --with-http_flv_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-stream \
    --with-mail \
    --with-mail_ssl_module \
    --user=nginx \
    --group=nginx \
    --prefix=$PREFIX \
    --conf-path=$CONFPATH/$PROG.conf \
    --pid-path=$RUNPATH/$PROG-$MAJVER.pid \
    --http-log-path=$LOGPATH/access.log \
    --error-log-path=$LOGPATH/error.log \
    --http-client-body-temp-path=/tmp/.nginx/body \
    --http-proxy-temp-path=/tmp/.nginx/proxy \
    --http-fastcgi-temp-path=/tmp/.nginx/fastcgi \
    --http-uwsgi-temp-path=/tmp/.nginx/uwsgi \
    --http-scgi-temp-path=/tmp/.nginx/scgi \
"

LDFLAGS+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

copy_man_page() {
    logmsg "--- copying man page"
    logcmd mkdir -p $DESTDIR$PREFIX/share/man/man8 || \
        logerr "--- creating man page directory failed"

    logcmd cp $TMPDIR/$BUILDDIR/man/$PROG.8 $DESTDIR$PREFIX/share/man/man8 || \
        logerr "--- copying man page failed"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
copy_man_page
install_smf network http-$PROG-$sMAJVER.xml http-$PROG-$sMAJVER
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
