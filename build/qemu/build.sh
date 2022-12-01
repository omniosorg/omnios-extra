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

PROG=qemu
VER=7.1.0
PKG=ooce/emulator/qemu
SUMMARY="$PROG"
DESC="A generic and open source machine emulator and virtualizer"

LIBTASN1VER=4.19.0

if [ $RELVER -lt 151045 ]; then
    logmsg "--- $PKG is not built for r$RELVER"
    exit 0
fi

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

init
prep_build

#########################################################################
# Download and build static versions of dependencies

save_buildenv

CONFIGURE_OPTS=" --disable-shared --enable-static"

build_dependency libtasn1 libtasn1-$LIBTASN1VER \
    $PROG/libtasn1 libtasn1 $LIBTASN1VER

restore_buildenv

CFLAGS+=" -I$DEPROOT$PREFIX/include"
LDFLAGS64+=" -L$DEPROOT$PREFIX/lib/$ISAPART64"

addpath PKG_CONFIG_PATH64 $DEPROOT$PREFIX/lib/$ISAPART64/pkgconfig

#########################################################################

note -n "-- Building $PROG"

CONFIGURE_CMD="/bin/bash $CONFIGURE_CMD"
CONFIGURE_OPTS="
    --localstatedir=/var$PREFIX
"
LDFLAGS+=" -lumem"

fixup() {
    # Meson strips runpaths when it installs objects, something which a lot
    # of different projects have had to patch around, see:
    #   https://github.com/mesonbuild/meson/issues/2567

    # For now, we patch the desired runpaths back into the installed objects
    # which also lets us move the libraries back to the usual location
    # (since meson also insists that libdir is a subdirectory of prefix)

    pushd $DESTDIR >/dev/null

    local P=${PREFIX#/}

    rpath64="/usr/gcc/$GCCVER/lib/$ISAPART64:$OPREFIX/lib/$ISAPART64"
    for obj in $P/bin/*; do
        [ -f "$obj" ] || continue
        logmsg "--- fixing runpath for $obj"
        if file $obj | $EGREP -s 'ELF 64-bit'; then
            logcmd elfedit -e "dyn:value -s RPATH $rpath64" $obj
            logcmd elfedit -e "dyn:value -s RUNPATH $rpath64" $obj
        else
            file $obj
            logerr "BAD"
        fi
    done
    popd >/dev/null
}

download_source $PROG $PROG $VER
patch_source
build
fixup
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
