#!/usr/bin/bash
#

# Copyright 2026 Tim Hawes

. ../../lib/build.sh

PROG=xstow
VER=1.1.1
PKG=ooce/application/xstow
SUMMARY="Program for managing symlinks for custom compiled software packages."
DESC="XStow is a replacement of GNU Stow (http://www.gnu.org/software/stow/) written in C++. It supports all features of Stow with some extensions."
CONFIGURE_OPTS+=" MAKE=gmake"
LDFLAGS[amd64]+=" -zignore"

set_arch 64

set_mirror "$GITHUB/majorkingleo/xstow/releases/download/$VER"
set_checksum sha256 "191535eb430f0456a5de3d82ff6a5f8c4a155ad3c6a65ecf80de7acf11065278"

# create package functions
init
download_source . $PROG $VER
patch_source
prep_build
build
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
