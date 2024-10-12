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

PROG=ripgrep
VER=14.1.1
PKG=ooce/text/ripgrep
SUMMARY="Fast line-oriented search tool"
DESC="A fast line-oriented search tool that recursively searches your current "
DESC+="directory for a regex pattern while respecting your gitignore rules"

BUILD_DEPENDS_IPS="
    ooce/developer/rust
    library/pcre2
"

set_arch 64

SKIP_LICENCES=UNLICENSE

pre_package() {
    typeset arch=$1

    # we cannot run the cross built binary, the best we can do is assume
    # that the build host runs the same version and use it to generate
    # the man page
    destdir=$DESTDIR
    if cross_arch $arch; then
        rg=$PREFIX/bin/rg
        destdir+=.$arch
    else
        rg=$destdir$PREFIX/bin/rg
    fi

    logmsg "generating man page"
    logcmd $MKDIR -p $destdir$PREFIX/share/man/man1 \
        || logerr "creating man dir failed"
    logcmd -p $rg --generate man \
        >| $destdir$PREFIX/share/man/man1/rg.1 \
        || logerr "generating man page failed"
}

init
download_source $PROG $VER
patch_source
prep_build
build_rust --features pcre2
PROG=rg install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
