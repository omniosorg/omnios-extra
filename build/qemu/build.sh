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

PROG=qemu
VER=8.1.2
PKG=ooce/emulator/qemu
SUMMARY="$PROG"
DESC="A generic and open source machine emulator and virtualizer"

LIBTASN1VER=4.19.0
LIBSLIRPVER=4.7.0
SPHINXVER=6.1.3
SPHINXRTDVER=1.2.0

min_relver 151044

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

CONFIGURE_OPTS=" -Ddefault_library=static"
LDFLAGS[amd64]+=" -lsocket"

build_dependency -meson libslirp libslirp-v$LIBSLIRPVER \
    $PROG/libslirp libslirp v$LIBSLIRPVER

CONFIGURE_OPTS=" --disable-shared --enable-static"

build_dependency libtasn1 libtasn1-$LIBTASN1VER \
    $PROG/libtasn1 libtasn1 $LIBTASN1VER

restore_buildenv

CFLAGS+=" -I$DEPROOT$PREFIX/include -I$DEPROOT$PREFIX/include/slirp"
LDFLAGS[amd64]+=" -L$DEPROOT$PREFIX/lib/amd64"

addpath PKG_CONFIG_PATH[amd64] $DEPROOT$PREFIX/lib/amd64/pkgconfig

pyvenv_install sphinx $SPHINXVER $TMPDIR/sphinx
pyvenv_install sphinx-rtd-theme $SPHINXRTDVER $TMPDIR/sphinx
PATH+=":$TMPDIR/sphinx/bin"

#########################################################################

note -n "-- Building $PROG"

# POSIX sigwait(2) plus strnlen visibility
set_standard POSIX+EXTENSIONS CFLAGS

CONFIGURE_OPTS="
    --localstatedir=/var$PREFIX
    --enable-docs
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

    rpath64="/usr/gcc/$GCCVER/lib/amd64:$OPREFIX/lib/amd64"
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
install_execattr
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
