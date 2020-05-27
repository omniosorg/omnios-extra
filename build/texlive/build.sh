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

# Copyright 2014 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=texlive
VER=20190410
PKG=ooce/application/texlive
SUMMARY="TeX Live"
DESC="LaTeX distribution"

# This component does not yet build with gcc 10
[ $GCCVER = 10 ] && set_gccver 9

OPREFIX=$PREFIX
PREFIX+=/$PROG

SKIP_LICENCES=TeXLive

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libpng
    ooce/library/cairo
"

XFORM_ARGS="-DPREFIX=${PREFIX#/}"

set_builddir $PROG-$VER-source

# texlive doesn't check for gmake
export MAKE

set_arch 64

CONFIGURE_OPTS_64="
    --prefix=$PREFIX
    --bindir=$PREFIX/bin
    --sysconfdir=/etc$PREFIX
    --disable-native-texlive-build
    --disable-static
    --disable-luajittex
    --without-x
    --with-gmp-includes=/usr/include/gmp
    --with-gmp-libdir=/usr/lib/$ISAPART64
    --with-system-cairo
    --with-system-freetype2
    --with-system-gmp
    --with-system-libpng
    --with-system-pixman
    --with-system-mpfr
    --with-system-zlib
    --build=$TRIPLET64
"

dl_dist() {
    for dist in texmf extra; do
        BUILDDIR=$PROG-$VER-$dist download_source $PROG $PROG-$VER-$dist
    done
}

install_dist() {
    dst="$DESTDIR$PREFIX/share"
    # manpages get installed from the source package into $PREFIX/share/man
    # already
    rm -rf $TMPDIR/$PROG-$VER-texmf/texmf-dist/doc/man
    logcmd mkdir -p $dst
    logmsg "--- Copying texmf"
    logcmd rsync -a $TMPDIR/$PROG-$VER-texmf/texmf-dist $dst/ \
        || logerr "rsync texmf"
    logmsg "--- Copying extra"
    logcmd rsync -a $TMPDIR/$PROG-$VER-extra/tlpkg $dst/ \
        || logerr "rsync extra"
    logcmd cp $TMPDIR/$PROG-$VER-extra/LICENSE.TL \
        $TMPDIR/$EXTRACTED_SRC/LICENSE.TL \
        || logerr "copy LICENSE.TL"
}

config_tex() {
    dir="$DESTDIR$PREFIX"
    cnf="$dir/share/texmf-dist/web2c/fmtutil.cnf"

    PATH=$dir/bin:$PATH logcmd texlinks -f $cnf $dir/bin \
        || logerr '--- texlinks failed'

    # disable formats (unavailable engine)
    for f in luajittex/luajittex; do
        PATH=$dir/bin:$PATH logcmd fmtutil-sys --cnffile $cnf --disablefmt $f
    done

    PATH=$dir/bin:$PATH logcmd fmtutil-sys --cnffile $cnf --missing \
        || logerr '--- fmtutil-sys failed'
}

make_install() {
    logmsg "--- make install"
    logcmd $MAKE DESTDIR=$DESTDIR install-strip \
        || logerr "--- Make install failed"
}

CFLAGS+=" -I$OPREFIX/include"
LDFLAGS64+=" -L$OPREFIX/lib/$ISAPART64 -R$OPREFIX/lib/$ISAPART64"
# export required, otherwise build will fail
# /usr/lib/$ISAPART64/pkgconfig for mpfr
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH64:/usr/lib/$ISAPART64/pkgconfig"

init
download_source $PROG $PROG $VER-source
patch_source
dl_dist
run_autoreconf
# texlive should be built out-of-tree
prep_build autoconf -oot
install_dist
build
config_tex
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
