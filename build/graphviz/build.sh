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
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --disable-static
    --disable-python2
    --without-visio
    --disable-php
    --includedir=$OPREFIX/include
    PS2PDF=/bin/true
"
CONFIGURE_OPTS[amd64]+="
    --libdir=$OPREFIX/lib/amd64
"

CPPFLAGS+=" -I$OPREFIX/include"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"

post_install() {
    logmsg "-- generating plugin configuration file"
    LD_LIBRARY_PATH=$DESTDIR$OPREFIX/lib/amd64 \
        GVBINDIR=$DESTDIR$OPREFIX/lib/amd64/$PROG \
         logcmd $DESTDIR$PREFIX/bin/dot -c -v || logerr "dot -c failed"
    egrep -s libgvplugin_core.so.6 \
        $DESTDIR$OPREFIX/lib/amd64/$PROG/config6 \
        || logerr "Plugin configuration file was not properly generated"

    # checks

    for opt in LIBGD FONTCONFIG FREETYPE2 PANGOCAIRO; do
        egrep -s "HAVE_$opt 1" $TMPDIR/$BUILDDIR/config.log \
            || logerr "Option $opt is not enabled"
    done
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
