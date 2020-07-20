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

PROG=mrtg
VER=2.17.7
PKG=ooce/network/mrtg
SUMMARY="Multi Router Traffic Grapher"
DESC="Monitor SNMP network devices and draw pretty pictures showing "
DESC+="how much traffic has passed through each interface."

set_arch 64

[ $RELVER -lt 151033 ] && RUN_DEPENDS_IPS+=" runtime/perl-64"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --with-gd-inc=$OPREFIX/include
    --with-gd-lib=$OPREFIX/lib/$ISAPART64
"

reset_configure_opts

LDFLAGS64+=" -R$OPREFIX/lib/$ISAPART64"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
