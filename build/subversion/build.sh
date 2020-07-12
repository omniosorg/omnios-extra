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

# Copyright 2020 OmniOS Community Edition.

. ../../lib/functions.sh

PROG=subversion
VER=1.14.0
PKG=ooce/developer/subversion
SUMMARY="Subversion is an open source version control system"
DESC="Subversion is a version control system designed to be \
as similar to cvs(1) as possible, while fixing many \
outstanding problems with cvs(1)."

set_arch 64
set_standard XPG6

BUILD_DEPENDS_IPS+="
    ooce/library/apr
    ooce/library/apr-util
    ooce/library/serf
"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS_64=" 
    --prefix=$PREFIX
    --with-apr=$OPREFIX/bin/$ISAPART64/apr-1-config
    --with-apr-util=$OPREFIX/bin/$ISAPART64/apu-1-config
    --with-utf8proc=internal
"

LDFLAGS+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
prep_build
build
strip_install
install_smf network subversion.xml
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
