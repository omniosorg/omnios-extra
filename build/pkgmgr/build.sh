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

PROG=pkgmgr
VER=github-latest
PKG=ooce/developer/pkgmgr
SUMMARY="IPS package manager"
DESC="IPS package management/publishing tool"

set_mirror "$OOCEGITHUB/$PROG/releases/download"
set_checksum sha256 \
    35d4c118e1b8863c0461ff20f14d08640a4906abf3b226c567c12cbe1e62bd87

RUN_DEPENDS_IPS="network/rsync"
[ $RELVER -lt 151033 ] && RUN_DEPENDS_IPS+=" runtime/perl-64"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
"

copy_config() {
    # copy config template
    logcmd cp $DESTDIR/etc$PREFIX/$PROG.conf.dist $DESTDIR/etc$PREFIX/$PROG.conf \
        || logerr "--- cannot copy config file template"
}

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
copy_config
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
