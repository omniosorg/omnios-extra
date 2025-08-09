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

PROG=apr
VER=1.7.6
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

export CC_FOR_BUILD=/opt/gcc-$DEFAULT_GCC_VER/bin/gcc

CONFIGURE_OPTS[i386]+="
    --with-installbuilddir=$PREFIX/share/apr/i386/build-1
"

CONFIGURE_OPTS[amd64]+="
    --with-installbuilddir=$PREFIX/share/apr/amd64/build-1
"

CONFIGURE_OPTS[aarch64]+="
    --with-installbuilddir=$PREFIX/share/apr/aarch64/build-1
    ac_cv_file__dev_zero=yes
    ac_cv_strerror_r_rc_int=yes
    apr_cv_process_shared_works=yes
    apr_cv_mutex_robust_shared=yes
    apr_cv_tcp_nodelay_with_cork=yes
"

# Run the test-suite for the 32-bit build too
post_install() {
    [ $1 != i386 ] && return

    run_testsuite test "" testsuite-32.log
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite
make_isa_stub
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
