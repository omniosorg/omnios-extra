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

PROG=pango
VER=1.51.0
PKG=ooce/library/pango
SUMMARY="pango"
DESC="Pango is a library for laying out and rendering of text"

# Dependencies
HARFBUZZVER=8.2.1
FRIBIDIVER=1.0.13

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

pre_configure() {
    typeset arch=$1

    LDFLAGS[$arch]+=" -L$PREFIX/${LIBDIRS[$arch]} -R$PREFIX/${LIBDIRS[$arch]}"
    [ $arch = i386 ] && LDFLAGS[$arch]+=" -lssp_ns"

    export MAKE
}

post_configure() {
    for flag in $EXPECTED_OPTIONS; do
        $EGREP -s "HAVE_$flag 1" config.h || logerr "HAVE_$flag not set"
    done
}

init
prep_build

######################################################################

# false positive due to the BUFFER_VERIFY_ERROR macro showing up in the build log
# since there will be one error in the log after the 32-bit build but two
# after the 64-bit build we disable error checking for harfbuzz but enable
# it afterwards and set the expected error count to 2
SKIP_BUILD_ERRCHK=1

EXPECTED_OPTIONS="CAIRO CAIRO_FT FREETYPE GLIB"
build_dependency -merge -noctf harfbuzz harfbuzz-$HARFBUZZVER \
    harfbuzz harfbuzz $HARFBUZZVER

export CPPFLAGS+=" -I$DEPROOT/$PREFIX/include/harfbuzz"

SKIP_BUILD_ERRCHK=
test_relver '>=' 151044 && EXPECTED_BUILD_ERRS=2

######################################################################

EXPECTED_OPTIONS=""
build_dependency -merge -noctf fribidi fribidi-$FRIBIDIVER \
    fribidi fribidi $FRIBIDIVER
export CPPFLAGS+=" -I$DEPROOT/$PREFIX/include/fribidi"

######################################################################

if ((EXTRACT_MODE == 0)); then
    logcmd find $DEPROOT -name \*.la -exec rm {} +
    logcmd mv $DEPROOT/$PREFIX/bin/amd64/* $DEPROOT/$PREFIX/bin/ \
        || logerr "relocate dependency binaries"
    logcmd rm -rf $DEPROOT/$PREFIX/bin/{i386,amd64}
fi

for arch in $DEFAULT_ARCH; do
    LDFLAGS[$arch]+=" -L$DEPROOT/$PREFIX/${LIBDIRS[$arch]}"
    addpath PKG_CONFIG_PATH[$arch] $DEPROOT/$PREFIX/${LIBDIRS[$arch]}/pkgconfig
done

CONFIGURE_OPTS="
    --prefix=$PREFIX
    -Db_asneeded=false
    -Dgtk_doc=false
    -Dinstall-tests=false
    -Dintrospection=disabled
"
CONFIGURE_OPTS[i386]=" --libdir=$PREFIX/lib "
CONFIGURE_OPTS[amd64]=" --libdir=$PREFIX/lib/amd64 "

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
        if file $obj | egrep -s 'ELF 64-bit'; then
            logcmd elfedit -e "dyn:value -s RPATH $rpath64" $obj
            logcmd elfedit -e "dyn:value -s RUNPATH $rpath64" $obj
        elif file $obj | egrep -s 'ELF 32-bit'; then
            logcmd elfedit -e "dyn:value -s RPATH $rpath32" $obj
            logcmd elfedit -e "dyn:value -s RUNPATH $rpath32" $obj
        else
            file $obj
            logerr "BAD"
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
