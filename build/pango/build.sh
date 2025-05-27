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

# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=pango
VER=1.56.3
PKG=ooce/library/pango
SUMMARY="pango"
DESC="Pango is a library for laying out and rendering of text"

forgo_isaexec

# Dependencies
HARFBUZZVER=11.2.1
FRIBIDIVER=1.0.16

export CC_FOR_BUILD=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc

# The icu4c ABI changes frequently. Lock the version
# pulled into each build of harfbuzz.
ICUVER=`pkg_ver icu4c`
ICUVER=${ICUVER%%.*}
BUILD_DEPENDS_IPS="
    =ooce/library/icu4c@$ICUVER
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/cairo
"

RUN_DEPENDS_IPS="
    =ooce/library/icu4c@$ICUVER
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DHARFBUZZ=$HARFBUZZVER
    -DFRIBIDI=$FRIBIDIVER
"

save_variable PKG_CONFIG_PATH

pre_configure() {
    typeset arch=$1

    _dd=$DESTDIR
    cross_arch $arch && _dd+=.$arch
    CPPFLAGS+=" -I$_dd$PREFIX/include/fribidi -I$_dd$PREFIX/include/harfbuzz"
    LDFLAGS[$arch]+=" -L$_dd$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -L${SYSROOT[$arch]}$PREFIX/${LIBDIRS[$arch]}"
    LDFLAGS[$arch]+=" -R$PREFIX/${LIBDIRS[$arch]}"
    [ $arch = i386 ] && LDFLAGS[$arch]+=" -lssp_ns"

    restore_variable PKG_CONFIG_PATH

    _pkgconfpath=${PKG_CONFIG_PATH[$arch]}
    PKG_CONFIG_PATH[$arch]="$_dd$PREFIX/${LIBDIRS[$arch]}/pkgconfig"
    PKG_CONFIG_PATH[$arch]+=":$_pkgconfpath"
    subsume_arch $arch PKG_CONFIG_PATH
    export PKG_CONFIG_PATH

    export MAKE
}

post_configure() {
    for flag in $EXPECTED_OPTIONS; do
        $EGREP -s "HAVE_$flag 1" config.h || logerr "HAVE_$flag not set"
    done
}

init
prep_build meson

######################################################################

save_buildenv

CONFIGURE_OPTS="--prefix=$PREFIX"
CONFIGURE_OPTS[aarch64]="
    --cross-file $BLIBDIR/meson-aarch64-gcc
"

build_dependency -meson -multi -merge -noctf fribidi fribidi-$FRIBIDIVER \
    fribidi fribidi $FRIBIDIVER

######################################################################

CXXFLAGS[aarch64]+=" -mno-outline-atomics"

build_dependency -meson -multi -merge -noctf harfbuzz harfbuzz-$HARFBUZZVER \
    harfbuzz harfbuzz $HARFBUZZVER

restore_buildenv

######################################################################

CONFIGURE_OPTS="
    --prefix=$PREFIX
    -Db_asneeded=false
    -Ddocumentation=false
    -Dintrospection=disabled
"
CONFIGURE_OPTS[i386]=" --libdir=$PREFIX/${LIBDIRS[i386]} "
CONFIGURE_OPTS[amd64]=" --libdir=$PREFIX/${LIBDIRS[amd64]} "
CONFIGURE_OPTS[aarch64]="
    --libdir=$PREFIX/${LIBDIRS[aarch64]}
    --cross-file $BLIBDIR/meson-aarch64-gcc
"

EXPECTED_OPTIONS="CAIRO CAIRO_FREETYPE CAIRO_PDF CAIRO_PS CAIRO_PNG FREETYPE"

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
    rpath64="/usr/gcc/$GCCVER/lib/amd64:$PREFIX/lib/amd64"
    for obj in $P/bin/* $P/lib/*.so* $P/lib/amd64/*.so*; do
        [ -f "$obj" ] || continue
        logmsg "--- fixing runpath for $obj"
        if $FILE $obj | egrep -s 'ELF 64-bit'; then
            logcmd elfedit -e "dyn:value -s RPATH $rpath64" $obj
            logcmd elfedit -e "dyn:value -s RUNPATH $rpath64" $obj
        elif $FILE $obj | egrep -s 'ELF 32-bit'; then
            logcmd elfedit -e "dyn:value -s RPATH $rpath32" $obj
            logcmd elfedit -e "dyn:value -s RUNPATH $rpath32" $obj
        else
            logerr "failed to determine ELF class of '$obj'"
        fi
    done
    popd >/dev/null
}

note -n "-- Building $PROG"

set_builddir $PROG-$VER
download_source $PROG $PROG $VER
patch_source
build
fixup
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
