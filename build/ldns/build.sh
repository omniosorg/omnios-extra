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

PROG=ldns
VER=1.8.3
PKG=ooce/library/ldns
SUMMARY=$PROG
DESC="$PROG DNS programming library and drill utility"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-static
    --disable-dane-ta-usage
"
CONFIGURE_OPTS[i386]+="
    --bindir=$PREFIX/bin/i386
"
CONFIGURE_OPTS[amd64]+="
    --bindir=$PREFIX/bin
    --with-drill
    --with-examples
"

# Building in parallel produces occasional bad objects that then fail the
# linking stage. This needs investigation but disabled parallelism for now.
NO_PARALLEL_MAKE=1

# The 'distclean' target clobbers too much including 'configure'
make_clean() {
    logcmd $MAKE clean
}

make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p amd64
    logcmd mv ldns-config amd64/ || logerr "mv ldns-config"
    make_isaexec_stub_arch amd64 $PREFIX/bin
    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
