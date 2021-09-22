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

# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=libcxx
PKG=ooce/library/libcxx
VER=12.0.1
SUMMARY="C++ standard library"
DESC="libc++ is a new implementation of the C++ standard library, "
DESC+="targeting C++11 and above."

set_builddir $PROG-$VER.src

CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64=
CONFIGURE_OPTS_WS="
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DLIBCXX_ENABLE_STATIC=OFF
    -DCMAKE_C_COMPILER=\"$CC\"
    -DCMAKE_CXX_COMPILER=\"$CXX\"
    -DPYTHON_EXECUTABLE=\"$PYTHON\"
"
CONFIGURE_OPTS_WS_32="
    -DCMAKE_CXX_LINK_FLAGS=\"$LDFLAGS32\"
"
[ $RELVER -ge 151037 ] && CONFIGURE_OPTS_WS_32+=" -DLIBCXX_LINK_SSP_NS=ON"
CONFIGURE_OPTS_WS_64="
    -DLLVM_LIBDIR_SUFFIX=/$ISAPART64
    -DCMAKE_CXX_LINK_FLAGS=\"$LDFLAGS64\"
"

download_deps() {
    for dist in ${PROG}abi llvm; do
        BUILDDIR=$dist-$VER.src download_source $dist $dist-$VER.src
        logcmd ln -f -s $TMPDIR/$dist-$VER.src $TMPDIR/$dist
    done
}

init
download_source $PROG $BUILDDIR
download_deps
patch_source
prep_build cmake+ninja
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
