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

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libpng
    ooce/library/cairo
"

set_builddir $PROG-$VER-source

# texlive doesn't check for gmake
export MAKE

OPREFIX=$PREFIX
PREFIX+=/$PROG

SKIP_LICENCES=TeXLive

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
    pushd $TMPDIR >/dev/null
    for dist in texmf extra; do
        DIR=$PROG-$VER-$dist
        FILENAME=$DIR.tar.xz
        logmsg "--- Downloading $dist archive"
        if ! [ -f $FILENAME ]; then
            get_resource $PROG/$FILENAME \
                || logerr "--- failed to download $dist"
        fi
        # Fetch and verify the archive checksum
        if [ -z "$SKIP_CHECKSUM" ]; then
            logmsg "Verifying checksum of downloaded file."
            if [ ! -f "$FILENAME.sha256" ]; then
                get_resource $PROG/$FILENAME.sha256 \
                    || logerr "Unable to download SHA256 checksum file for $FILENAME"
            fi
            if [ -f "$FILENAME.sha256" ]; then
                sum="`digest -a sha256 $FILENAME`"
                [ "$sum" = "`cat $FILENAME.sha256`" ] \
                    || logerr "Checksum of downloaded file does not match."
            fi
        fi
        [ -d "$DIR" ] && logcmd rm -rf "$DIR"
        logmsg "--- Extracting $dist archive"
        logcmd extract_archive $FILENAME \
            || logerr "--- failed to extract $dist"
    done
    popd >/dev/null
}

install_dist() {
    mkdir -p $DESTDIR$PREFIX/share
    # manpages get installed from the source package into $PREFIX/share/man
    # already
    rm -rf $TMPDIR/$PROG-$VER-texmf/texmf-dist/doc/man
    # we don't want the python/ruby stuff
    logmsg "--- Copying texmf"
    logcmd cp -RP $TMPDIR/$PROG-$VER-texmf/texmf-dist $DESTDIR$PREFIX/share/
    logmsg "--- Copying extra"
    logcmd cp -RP $TMPDIR/$PROG-$VER-extra/tlpkg $DESTDIR$PREFIX/share/
    logcmd cp $TMPDIR/$PROG-$VER-extra/LICENSE.TL $TMPDIR/$EXTRACTED_SRC/LICENSE.TL
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
