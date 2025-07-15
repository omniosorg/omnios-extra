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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=lrzsz
VER=0.12.20
PKG=ooce/util/lrzsz
SUMMARY="$PROG - x/y/zmodem implementation"
DESC="$PROG is a UNIX communication package providing the XMODEM, YMODEM and "
DESC+="ZMODEM file transfer protocols."

set_arch 64

HARDLINK_TARGETS="
    opt/ooce/bin/rx
    opt/ooce/bin/sx
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

# The files delivered are prefixed by 'l' by default. Remove that.
CONFIGURE_OPTS+="
    --program-transform-name='s/^l//'
"

# The configure script looks for a libbe and links it in if found (for syslog
# support on some platforms) - we don't want to link our boot environment
# library!
export ac_cv_lib_be_syslog=no

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
