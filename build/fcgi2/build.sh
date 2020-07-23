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

PROG=fcgi2
VER=2.4.2
PKG=ooce/library/fcgi2
SUMMARY="FactCGI Library"
DESC="FastCGI.com fcgi2 Development Kit fork from \
http://repo.or.cz/fcgi2.git + last snapshot"

SKIP_LICENCES=OMI

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

# SHELL gets overwritten with CONFIG_SHELL
export CONFIG_SHELL=$SHELL

# Skip isaexec and deliver 64-bit binaries directly to bin and sbin
# 32-bit binaries are stripped in local.mog
CONFIGURE_OPTS_64+=" --bindir=$PREFIX/bin"

# $MAKE distclean wipes configure; rerun autoreconf
save_function configure64 _configure64
configure64() {
    run_autoreconf -i
    _configure64
}

init
download_source $PROG $VER
run_autoreconf -i
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
