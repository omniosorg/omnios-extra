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

PROG=mod_md
VER=2.4.0
# Hard-coded here for now. If we ship more than one apache version, this will
# need restructuring.
PKG=ooce/server/apache-24/modules/md
SUMMARY="$PROG Let's Encrypt (ACME) support for Apache httpd"
DESC="$SUMMARY"

APACHEVER=2.4
sAPACHEVER=${APACHEVER//./}

RUN_DEPENDS_IPS+=" ooce/server/apache-$sAPACHEVER"

set_arch 64

set_mirror 'https://github.com/icing/mod_md/releases/download/'
set_checksum sha256 \
    '1710ffe0931a396f155c922d6873e56e3d4947c46f39094a428a766672f1ef91'

OPREFIX=$PREFIX
PREFIX+="/apache-$APACHEVER"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

export PATH+=":$PREFIX/bin"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
CFLAGS64+=" -D_XOPEN_SOURCE=700"
CPPFLAGS64+=" -I /usr/include"

CONFIGURE_CMD="./configure --with-apxs="$PREFIX/bin/apxs""

init
download_source "v.$VER" "$PROG-$VER"
patch_source
prep_build
build -ctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
