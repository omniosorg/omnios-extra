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

# Copyright 2019 OmniOS Community Edition.  All rights reserved.

. ../../lib/functions.sh

PROG=jq
PKG=ooce/util/jq
VER=1.6
SUMMARY="$PROG - JSON query tool"
DESC="$PROG is a lightweight and flexible command-line JSON processor"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --with-oniguruma=builtin
"

save_function prep_build _prep_build
prep_build() {
    pushd $TMPDIR/$BUILDDIR/modules/oniguruma >/dev/null
    [ -f configure ] && logerr "--- looks like modules/oniguruma is fixed"
    autoreconf -fi
    popd >/dev/null

    _prep_build
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
