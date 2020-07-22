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

PROG=nagios-nrdp
VER=2.0.3
PKG=ooce/application/nagios-nrdp
SUMMARY="Nagios Remote Data Processor"
DESC="NRDP is a flexible data transport mechanism and processor \
for Nagios. It is designed with a simple and powerful architecture \
that allows for it to be easily extended and customized to fit \
individual users' needs. It uses standard ports protocols (HTTP(S) \
and XML) and can be implemented as a replacement for NSCA."

BUILDDIR=nrdp-$VER

RUN_DEPENDS_IPS+="
    ooce/application/nagios-common
"

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

build() {
    logcmd mkdir -p $DESTDIR/$PREFIX/nagios/nrdp || logerr "mkdir"
    logcmd cp -r $TMPDIR/$BUILDDIR/server/* $DESTDIR/$PREFIX/nagios/nrdp \
        || logerr "cp -r server failed"
}

init
download_source nagios nrdp $VER
patch_source
prep_build
build
add_notes README.install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
