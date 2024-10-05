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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=ruby
VER=3.3.5
PKG=ooce/runtime/ruby-33
SUMMARY="Ruby"
DESC="A dynamic, open source programming language "
DESC+="with a focus on simplicity and productivity."

MAJVER=${VER%.*}
sMAJVER=${MAJVER//./}
set_patchdir patches-$sMAJVER

OPREFIX=$PREFIX
PREFIX+=/$PROG-$MAJVER

# does not yet build with gcc 14
((GCCVER > 13)) && set_gccver 13

set_arch 64

NO_SONAME_EXPECTED=1

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG-$MAJVER
    -DMEDIATOR=$PROG -DMEDIATOR_VERSION=$MAJVER
    -DVERSION=$MAJVER
    -DsVERSION=$sMAJVER
"

CONFIGURE_OPTS[amd64]+="
    --disable-install-doc
    --libdir=$PREFIX/lib
"

CPPFLAGS+=" -I/usr/include/gmp"
LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64"

subsume_arch $BUILDARCH PKG_CONFIG_PATH

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
