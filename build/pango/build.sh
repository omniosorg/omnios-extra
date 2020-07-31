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

PROG=pango
VER=1.45.4
PKG=ooce/library/pango
SUMMARY="pango"
DESC="Pango is a library for laying out and rendering of text"

# Dependencies
HARFBUZZVER=2.6.8
FRIBIDIVER=1.0.9

BUILD_DEPENDS_IPS="
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/cairo
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DHARFBUZZ=$HARFBUZZVER
    -DFRIBIDI=$FRIBIDIVER
"

LDFLAGS32+=" -L$PREFIX/lib -R$PREFIX/lib"
LDFLAGS64+=" -L$PREFIX/lib/$ISAPART64 -R$PREFIX/lib/$ISAPART64"

export MAKE

test_config() {
    for flag in $EXPECTED_OPTIONS; do
        egrep -s "HAVE_$flag 1" config.h || logerr "HAVE_$flag not set"
    done
}

save_function configure32 _configure32
configure32() {
    _configure32
    test_config
}

save_function configure64 _configure64
configure64() {
    _configure64
    test_config
}

init
prep_build

######################################################################

EXPECTED_OPTIONS="CAIRO CAIRO_FT FONTCONFIG FREETYPE GLIB"
build_dependency -merge harfbuzz harfbuzz-$HARFBUZZVER \
    harfbuzz harfbuzz $HARFBUZZVER

export CPPFLAGS+=" -I$DEPROOT/$PREFIX/include/harfbuzz"

######################################################################

EXPECTED_OPTIONS=""
build_dependency -merge fribidi fribidi-$FRIBIDIVER \
    fribidi fribidi $FRIBIDIVER
export CPPFLAGS+=" -I$DEPROOT/$PREFIX/include/fribidi"

######################################################################

logcmd find $DEPROOT -name \*.la -exec rm {} +
logcmd mv $DEPROOT/$PREFIX/bin/$ISAPART64/* $DEPROOT/$PREFIX/bin/ \
    || logerr "relocate dependency binaries"
logcmd rm -rf $DEPROOT/$PREFIX/bin/{$ISAPART,$ISAPART64}

LDFLAGS32+=" -L$DEPROOT/$PREFIX/lib"
LDFLAGS64+=" -L$DEPROOT/$PREFIX/lib/$ISAPART64"
addpath PKG_CONFIG_PATH32 $DEPROOT/$PREFIX/lib/pkgconfig
addpath PKG_CONFIG_PATH64 $DEPROOT/$PREFIX/lib/$ISAPART64/pkgconfig

CONFIGURE_OPTS="
    --prefix=$PREFIX
    -Db_asneeded=false
    -Dgtk_doc=false
    -Dinstall-tests=false
    -Dintrospection=false
"
CONFIGURE_OPTS_32="
    --libdir=$PREFIX/lib
"
CONFIGURE_OPTS_64="
    --libdir=$PREFIX/lib/$ISAPART64
"

EXPECTED_OPTIONS="CAIRO CAIRO_FREETYPE CAIRO_PDF CAIRO_PS CAIRO_PNG FREETYPE"

# meson will not re-configure without --wipe and will not --wipe unless it
# has already been configured. Until the framework is updated to automatically
# use separate directories for each arch, wipe the build directory between
# builds.
make_clean() {
    logmsg "--- make (dist)clean"
    [ -d $TMPDIR/$BUILDDIR ] && logcmd rm -rf $TMPDIR/$BUILDDIR
}

fixup() {
    # Meson strips runpaths when it installs objects, something which a lot
    # of different projects have had to patch around, see:
    #   https://github.com/mesonbuild/meson/issues/2567

    # For now, we patch the desired runpaths back into the installed objects
    # which also lets us move the libraries back to the usual location
    # (since meson also insists that libdir is a subdirectory of prefix)

    pushd $DESTDIR >/dev/null

    local P=${PREFIX#/}

    rpath32="/usr/gcc/$GCCVER/lib:$PREFIX/lib"
    rpath64="/usr/gcc/$GCCVER/lib/$ISAPART64:$PREFIX/lib/$ISAPART64"
    for obj in $P/bin/* $P/lib/*.so* $P/lib/$ISAPART64/*.so*; do
        [ -f "$obj" ] || continue
        if ! elfdump -d $obj | egrep -s RPATH; then
            logmsg "--- fixing runpath for $obj"
            if file $obj | egrep -s 'ELF 64-bit'; then
                logcmd elfedit -e "dyn:value -s RUNPATH $rpath64" $obj
            elif file $obj | egrep -s 'ELF 32-bit'; then
                logcmd elfedit -e "dyn:value -s RUNPATH $rpath32" $obj
            else
                file $obj
                logerr "BAD"
            fi
        fi
    done
    popd >/dev/null
}

note -n "-- Building $PROG"

download_source $PROG $PROG $VER
patch_source
prep_build meson -keep
build
fixup
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
