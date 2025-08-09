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

PROG=oath-toolkit
VER=2.6.13
PKG=ooce/security/oath-toolkit
SUMMARY="OATH Toolkit"
DESC="One-time password components"

test_relver '>=' 151055 && set_clangver

forgo_isaexec
# For the standard getpwnam_r
set_standard XPG6

# For memset_s
CPPFLAGS+=" -D__STDC_WANT_LIB_EXT1__"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
"

CONFIGURE_OPTS="--disable-static"

pre_configure() {
    typeset arch=$1

    PAMDIR=${LIBDIRS[$arch]/lib/security}
    CONFIGURE_OPTS[$arch]+=" --with-pam-dir=$PAMDIR"
    true
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
