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
#
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=guile
VER=2.0.14
PKG=ooce/library/guile
SUMMARY="GNU Ubiquitous Intelligent Language for Extensions"
DESC="$PROG - $SUMMARY"

BUILD_DEPENDS_IPS="ooce/library/unistring ooce/library/bdw-gc"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

# source and pre-compiled files must preserve timestamps
PKG_INCLUDE_TS+=" *.scm *.go"

CPPFLAGS+=" -I/usr/include/gmp -I$OPREFIX/include"
LDFLAGS+="-lsocket -lnsl"

export BDW_GC_CFLAGS="-I$OPREFIX/include"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --includedir=$OPREFIX/include
    --disable-error-on-warning
    --disable-static
    ac_cv_type_complex_double=no
"
CONFIGURE_OPTS[i386]="
    --bindir=$PREFIX/bin/i386
    --libdir=$OPREFIX/lib
"
CONFIGURE_OPTS[amd64]="
    --bindir=$PREFIX/bin
    --libdir=$OPREFIX/lib/amd64
"

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -L$OPREFIX/${LIBDIRS[$arch]} -R$OPREFIX/${LIBDIRS[$arch]}"

    export BDW_GC_LIBS="$LDFLAGS ${LDFLAGS[$arch]} -lgc"
}

# Make ISA binaries for guile-config, to allow software to find the
# right settings for 32/64-bit when pkg-config is not used.
make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p amd64
    logcmd mv guile-config amd64/ || logerr "mv guile-config"
    make_isaexec_stub_arch amd64 $PREFIX/bin
    popd >/dev/null
}

# make sure pre-compiled files are newer than sources
set_timestamps() {
    pushd $DESTDIR$OPREFIX/lib >/dev/null
    logcmd $FD -e go -X $TOUCH \
        || logerr "setting timestamps on pre-compiled files failed"
    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
set_timestamps
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
