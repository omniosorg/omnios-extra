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

# Copyright 2022 r7st r7st.guru@gmail.com
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=rlwrap
VER=0.46.1
PKG=ooce/util/rlwrap
SUMMARY="readline wrapper"
DESC="rlwrap is a 'readline wrapper', a small utility that uses the GNU "
DESC+="Readline library to allow the editing of keyboard input for any command."

set_arch 64

pre_configure() {
    typeset arch=$1

    CPPFLAGS[$arch]+=" -I${SYSROOT[$arch]}/usr/include"
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
