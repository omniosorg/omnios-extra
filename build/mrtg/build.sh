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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=mrtg
VER=2.17.10
PKG=ooce/network/mrtg
SUMMARY="Multi Router Traffic Grapher"
DESC="Monitor SNMP network devices and draw pretty pictures showing "
DESC+="how much traffic has passed through each interface."

set_arch 64

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS=" --with-gd-inc=$OPREFIX/include "

reset_configure_opts

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]+=" --with-gd-lib=$OPREFIX/${LIBDIRS[$arch]} "
    LDFLAGS[$arch]+=" -R$OPREFIX/${LIBDIRS[$arch]} "
}

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
