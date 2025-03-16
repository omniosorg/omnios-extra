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

PROG=fdt-tools
# there are no versions/tags, don't add this package to packages.md
# the source is taken from https://github.com/devicetree-org/fdt-tools
# version taken from meson.build
VER=1.7.0
PKG=ooce/developer/fdt-tools
SUMMARY="FDT tools"
DESC="Flattened Device Tree (FDT) tools"

min_rel 151053

forgo_isaexec
set_clangver
set_builddir $PROG-master

TESTSUITE_SED='
    1,/run-test/d
    /^Full log written to/d
'

pre_configure() {
    typeset arch=$1

    CONFIGURE_OPTS[$arch]="
        --prefix=$PREFIX
        --libdir=$PREFIX/${LIBDIRS[$arch]}
    "

    [ "$arch" = i386 ] && CONFIGURE_OPTS[$arch]+=" -Dtests=false"
    LDFLAGS[$arch]+=" -Wl,-R$PREFIX/${LIBDIRS[$arch]}"

    ! cross_arch $arch && return

    CONFIGURE_CMD+=" --cross-file $BLIBDIR/meson-$arch-gcc"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build meson
build
run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
