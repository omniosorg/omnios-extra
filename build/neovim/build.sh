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

PROG=neovim
VER=0.10.4
PKG=ooce/editor/neovim
SUMMARY="Neovim"
DESC="hyperextensible Vim-based text editor"

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64
set_clangver
export CC

# luaJIT build requires GNU tools
PATH="$GNUBIN:$PATH"

TESTSUITE_SED='
    1,/Global test environment setup/d
    s/[0-9][0-9.]*  *ms//
    s/[0-9]*-[0-9]*-[0-9]*T[0-9]*:[0-9]*:[0-9.]*//
'

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPKGROOT=$PROG
"

pre_configure() {
    typeset arch=$1

    MAKE_ARGS_WS="
        CMAKE_BUILD_TYPE=Release
        CMAKE_INSTALL_PREFIX=$PREFIX
        BUNDLED_CMAKE_FLAG=\"
            -DUSE_BUNDLED_GPERF=OFF
            -DUSE_BUNDLED_LIBUV=OFF
        \"
        CMAKE_EXTRA_FLAGS=\"
            -DCMAKE_EXE_LINKER_FLAGS='-Wl,-R$OPREFIX/${LIBDIRS[$arch]} -lgcc_s
            -lumem'
        \"
    "

    export CMAKE_LIBRARY_PATH=$OPREFIX/${LIBDIRS[$arch]}

    # no configure
    false
}

init
download_source $PROG v$VER
patch_source
prep_build
build
#run_testsuite
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
