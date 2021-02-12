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

PROG=subversion
VER=1.14.1
PKG=ooce/developer/subversion
SUMMARY="Subversion is an open source version control system"
DESC="Subversion is a version control system designed to be \
as similar to cvs(1) as possible, while fixing many \
outstanding problems with cvs(1)."

# Hard-coded here for now. If we eventually ship more apache modules, or ship
# more than one apache version, this will need restructuring.
APACHEVER=2.4
sAPACHEVER=${APACHEVER//./}

set_arch 64
set_standard XPG6

SKIP_RTIME_CHECK=1

BUILD_DEPENDS_IPS+="
    ooce/library/apr
    ooce/library/apr-util
    ooce/library/serf
    ooce/server/apache-$sAPACHEVER
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DAPACHE_VER=$APACHEVER
    -DAPACHE_SVER=$sAPACHEVER
    -DPROG=$PROG
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --with-utf8proc=internal
    --disable-mod-activation
    --with-apxs=$OPREFIX/apache-$APACHEVER/bin/apxs
"

LDFLAGS+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
prep_build
build
strip_install
install_smf application $PROG.xml
make_package svn.mog

PKG=ooce/server/apache-$sAPACHEVER/modules/subversion ##IGNORE##
SUMMARY="Subversion module for Apache Web Server $APACHEVER"
DESC="$SUMMARY"
make_package module.mog

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
