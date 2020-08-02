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

PROG=zadm
VER=github-latest
PKG=ooce/util/zadm
SUMMARY="zone admin tool"
DESC="$PROG - $SUMMARY"

if [ $RELVER -lt 151034 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

set_mirror "$OOCEGITHUB/$PROG/releases/download"

# Curl 7.71 is required as zadm uses the '%{json}' token
RUN_DEPENDS_IPS="
    web/curl@7.71.1
    network/socat
    ooce/compress/pigz
    ooce/compress/pbzip2
    ooce/compress/zstd
"

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
    --localstatedir=/var$PREFIX
"

init
download_source "v$VER" $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
