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

PROG=libuv
VER=1.41.0
PKG=ooce/library/libuv
SUMMARY=$PROG
DESC="Multi-platform support library with a focus on asynchronous I/O."

CONFIGURE_OPTS+="
    --disable-static
"

TESTSUITE_SED='
    # Remove test numbers
    s/ [0-9][0-9]* - / - /
    /^ok/p
    /^not ok/p
    /failed/p
    d
'

init
download_source $PROG v$VER
patch_source
prep_build
run_inbuild "./autogen.sh"
build -ctf
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
