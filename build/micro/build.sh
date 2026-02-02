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
#
# Copyright 2025 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=micro
PROGNAME=micro

VER=2.0.15
PKG=ooce/editor/micro
SUMMARY="$PROG - modern and intuitive terminal-based text editor"
DESC=`cat <<'EOM'
Micro is a terminal-based text editor that aims to be easy to use and
intuitive, while also taking advantage of the full capabilities of modern
terminals. As the name indicates, micro aims to be somewhat of a successor to
the nano editor by being easy to install and use in a pinch, but micro also
aims to be enjoyable to use full time, whether you work in the terminal because
you prefer it, or because you need to.
EOM
`

OPREFIX=$PREFIX
PREFIX+="/$PROG"

set_arch 64
set_gover

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

SKIP_LICENCES=Various

pre_configure() {
    # No configure
    false
}

pre_install() {
    install_go $PROG
    false
}

init
download_source $PROG v$VER
patch_source
prep_build
build -noctf
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
