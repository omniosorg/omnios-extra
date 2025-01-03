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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=qemu
VER=9.2.0
PKG=ooce/emulator/qemu
SUMMARY="$PROG"
DESC="A generic and open source machine emulator and virtualizer"

LIBSLIRPVER=4.8.0
IMGHDRVER=3.13.0

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64
test_relver '>=' 151053 && set_clangver

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
    -DSHIPETC=
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

restore_buildenv

CFLAGS+=" -I$DEPROOT$PREFIX/include/slirp"
LDFLAGS[amd64]+=" -L$DEPROOT$PREFIX/lib/amd64"

addpath PKG_CONFIG_PATH[amd64] $DEPROOT$PREFIX/lib/amd64/pkgconfig

#########################################################################

note -n "-- Building $PROG"

post_patch() {
    typeset dir="$1"

    # PEP 594 removed several modules ("dead batteries") starting in Python
    # 3.13. Since sphinx depends on imghdr, we need to explicitly re-add the
    # standard module to the temporary virtual environment until this is fixed
    # upstream.
    ((PYTHONPKGVER >= 313)) || return

    echo "standard-imghdr==$IMGHDRVER" >> $dir/docs/requirements.txt
    $SED -i "/sphinx_rtd_theme/a\\
standard-imghdr = { installed = \"$IMGHDRVER\" }
    " $dir/pythondeps.toml || logerr "sphinx imghdr insertion failed"
}

# POSIX sigwait(2) plus strnlen visibility
set_standard POSIX+EXTENSIONS CFLAGS

CONFIGURE_OPTS="
    --localstatedir=/var$PREFIX
    --enable-docs
"
LDFLAGS+=" -lumem"

post_install() {
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

    manifest_start $TMPDIR/manifest.img
    manifest_add $PREFIX/bin qemu-img
    manifest_add $PREFIX/share/man/man1 'qemu-img\.1'
    manifest_finalise $TMPDIR/manifest.img $OPREFIX

    manifest_uniq $TMPDIR/manifest.{qemu,img}
    manifest_finalise $TMPDIR/manifest.qemu $OPREFIX
}

download_source $PROG $PROG $VER
patch_source
build
PKG="ooce/util/$PROG-img" DESC="$PROG-img" SUMMARY="$PROG-img utility" \
    XFORM_ARGS+=" -DSHIPETC=#" make_package -seed $TMPDIR/manifest.img
install_execattr
RUN_DEPENDS_IPS="ooce/util/$PROG-img" \
    make_package -seed $TMPDIR/manifest.qemu
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
