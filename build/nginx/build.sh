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
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
# Use is subject to license terms.
#
# Load support functions
. ../../lib/functions.sh

PROG=nginx
VER=1.12.2
VERHUMAN=$VER
PKG=ooce/server/nginx
SUMMARY="nginx web server"
DESC="nginx is a high-performance HTTP(S) server and reverse proxy"

BUILD_DEPENDS_IPS="library/security/openssl library/pcre"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"
BUILDARCH=64

MAJVER=${VER%.*}
OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER
CONFPATH=/etc$OPREFIX/$PROG
LOGPATH=/var/log$OPREFIX/$PROG
RUNPATH=/var$OPREFIX/$PROG/run

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$MAJVER
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
    --conf-path=$CONFPATH/nginx.conf \
    --pid-path=$RUNPATH/nginx.pid \
    --http-log-path=$LOGPATH/access.log \
    --error-log-path=$LOGPATH/error.log \
    --http-client-body-temp-path=/tmp/.nginx/body \
    --http-proxy-temp-path=/tmp/.nginx/proxy \
    --http-fastcgi-temp-path=/tmp/.nginx/fastcgi \
    --http-uwsgi-temp-path=/tmp/.nginx/uwsgi \
    --http-scgi-temp-path=/tmp/.nginx/scgi \
"
LDFLAGS+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
install_smf network http-nginx.xml http-nginx
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
