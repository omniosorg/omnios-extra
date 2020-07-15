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

PROG=fping
VER=4.3
PKG=ooce/network/fping
SUMMARY="fping - send ICMP echo probes to network hosts"
DESC="fping is a program to send ICMP echo probes to network hosts, similar to "
DESC+="ping, but much better performing when pinging multiple hosts."

set_arch 64
set_standard XPG6

SKIP_LICENCES=fping
XFORM_ARGS="-DPREFIX=${PREFIX#/}"
CONFIGURE_OPTS="--bindir=$PREFIX/bin"

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
