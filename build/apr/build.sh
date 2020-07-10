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

# Copyright 2020 OmniOS Community Edition.

. ../../lib/functions.sh

PROG=apr
VER=1.7.0
PKG=ooce/library/apr
SUMMARY="The Apache Portable Runtime library"
DESC="The Apache Portable Runtime is a library \
of C data structures and routines, forming a system portability \
layer that covers as many operating systems as possible, including \
Unices, Win32, BeOS, OS/2."

CONFIGURE_OPTS="
    --disable-static
    apr_cv_pthreads_lib=
"

CONFIGURE_OPTS_32+="
    --with-installbuilddir=$PREFIX/share/apr/$ISAPART/build-1
"

CONFIGURE_OPTS_64+="
    --with-installbuilddir=$PREFIX/share/apr/$ISAPART64/build-1
"

# Run the test-suite for the 32-bit build too
make_install32() {
    make_install
    run_testsuite test "" testsuite-32.log
}

init
download_source $PROG $PROG $VER
prep_build
build -ctf
run_testsuite
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
