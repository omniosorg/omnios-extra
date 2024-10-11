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

PROG=rustdesk-server
VER=1.1.12
PKG=ooce/application/rustdesk-server
SUMMARY="$PROG - remote control"
DESC="Full-featured open source remote control alternative for self-hosting "
DESC+="and security with minimal configuration"

set_arch 64

OPREFIX=$PREFIX
PREFIX+=/$PROG

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DUTIL=rustdesk-utils
    -DUSER=rustdesk
    -DGROUP=rustdesk
"

SKIP_SSP_CHECK=1
# node contains BMI instructions even when built on an older CPU
BMI_EXPECTED=1

pre_build() {
    typeset arch=$1

    export RUSTFLAGS="-C link-arg=-R$OPREFIX/${LIBDIRS[$arch]}"
    # rust runs objects during the build which don't have the library
    # runtime path set, yet
    export LD_LIBRARY_PATH="$OPREFIX/${LIBDIRS[$arch]}"
}

init
download_source $PROG $VER
patch_source
prep_build
SODIUM_USE_PKG_CONFIG=1 build_rust
for f in hbbr hbbs rustdesk-utils; do install_rust $f; done
strip_install
xform files/rustdesk-template.xml > $TMPDIR/rustdesk.xml
install_smf ooce rustdesk.xml
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
