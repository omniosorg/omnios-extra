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

PROG=graphviz
VER=2.44.1
PKG=ooce/application/graphviz
SUMMARY="graphviz"
DESC="Graph visualisation software"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

SKIP_LICENCES=Eclipse

set_arch 64

BUILD_DEPENDS_IPS="
    ooce/library/pango
    ooce/library/libgd
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-static
    --disable-python2
    --without-visio
    --includedir=$OPREFIX/include
    --libdir=$OPREFIX/lib/$ISAPART64
    PS2PDF=/bin/true
"

CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"

checks() {
    for opt in LIBGD FONTCONFIG FREETYPE2 PANGOCAIRO; do
        egrep -s "HAVE_$opt 1" $TMPDIR/$BUILDDIR/config.log \
            || logerr "Option $opt is not enabled"
    done
}

save_function make_install _make_install
make_install() {
    _make_install "$@"
    logmsg "-- generating plugin configuration file"
    LD_LIBRARY_PATH=$DESTDIR$OPREFIX/lib/$ISAPART64 \
        GVBINDIR=$DESTDIR$OPREFIX/lib/$ISAPART64/$PROG \
         logcmd $DESTDIR$PREFIX/bin/dot -c -v || logerr "dot -c failed"
    egrep -s libgvplugin_core.so.6 \
        $DESTDIR$OPREFIX/lib/$ISAPART64/$PROG/config6 \
        || logerr "Plugin configuration file was not properly generated"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
checks
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
