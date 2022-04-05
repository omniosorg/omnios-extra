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

PROG=icu4c
VER=70.1
PKG=ooce/library/icu4c
SUMMARY="ICU - International Components for Unicode"
DESC="A mature, widely used set of C/C++ libraries providing "
DESC+="Unicode and Globalization support for software applications"

set_builddir icu/source

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

CONFIGURE_OPTS="--disable-samples"
CONFIGURE_OPTS_64+="
    --bindir=$PREFIX/bin
    --sbindir=$PREFIX/sbin
"

LDFLAGS32+=" -R$PREFIX/lib"
LDFLAGS64+=" -R$PREFIX/lib/$ISAPART64"

# Make ISA binaries for icu-config, to allow software to find the
# right settings for 32/64-bit when pkg-config is not used.
make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p $ISAPART64
    logcmd mv icu-config $ISAPART64/ || logerr "mv icu-config"
    make_isaexec_stub_arch $ISAPART64 $PREFIX/bin
    popd >/dev/null
}

init
download_source $PROG $PROG-${VER//./_}-src
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
