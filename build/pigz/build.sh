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

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pigz
PKG=ooce/compress/pigz
VER=2.7
SUMMARY=$PROG
DESC="Parallel implementation of gzip for modern "
DESC+="multi-processor, multi-core machines"

SKIP_LICENCES=pigz

set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
"

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        -e
        CFLAGS=\"${CFLAGS[$arch]} $CFLAGS\"
        LDFLAGS=\"${LDFLAGS[$arch]} -L${SYSROOT[$arch]}/usr/${LIBDIRS[$arch]} $LDFLAGS\"
        LIBS=\"-lm -lz\"
    "

    # no configure
    false
}

make_install() {
    for d in bin share/man/man1; do
        logcmd $MKDIR -p $DESTDIR$PREFIX/$d
    done

    logcmd $CP $TMPDIR/$BUILDDIR/$PROG \
        $DESTDIR$PREFIX/bin/$PROG
    logcmd $CP $TMPDIR/$BUILDDIR/$PROG.1 \
        $DESTDIR$PREFIX/share/man/man1/$PROG.1

    # extract licence
    $SED '2,/^The license/d' < $TMPDIR/$BUILDDIR/README \
        > $TMPDIR/$BUILDDIR/LICENCE
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
