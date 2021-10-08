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

# Copyright 2021 Sebastien Perreault

. ../../lib/functions.sh

PROG=byobu
VER=5.133
PKG=ooce/terminal/byobu
SUMMARY="Byobu is a GPLv3 open source text-based window manager and terminal \
    multiplexer."
DESC="Byobu was originally designed to provide elegant enhancements to the \
    otherwise functional, plain, practical GNU Screen, for the Ubuntu server \
    distribution. Byobu now includes an enhanced profiles, convenient \
    keybindings, configuration utilities, and toggle-able system status \
    notifications for both the GNU Screen window manager and the more modern \
    Tmux terminal multiplexer, and works on most Linux, BSD, and Mac \
    distributions."

RUN_DEPENDS_IPS+=" runtime/python-$PYTHONPKGVER"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

CONFIGURE_OPTS="--sysconfdir=/etc$OPREFIX"

fix_shebang() {
    logmsg "--- replacing /bin/sh with /bin/bash"
    logcmd $PERL -i -pe 's%^#!/bin/sh%#!/bin/bash%' \
        `$RIPGREP -l '^#!/bin/sh' $TMPDIR/$BUILDDIR`
}

init
download_source $PROG ${PROG}_$VER.orig
patch_source
fix_shebang
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
