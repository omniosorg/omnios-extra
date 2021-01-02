#!/usr/bin/bash
#
# {{{
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
# Copyright 2020 David Stes
# GNU Smalltalk latest stable 3.2.5 with some patches from 3.2.91 alpha

. ../../lib/functions.sh

PROG=gnu-smalltalk
VER=3.2.5
PKG=ooce/runtime/gnu-smalltalk
SUMMARY="GNU Smalltalk"
DESC="A free implementation of the Smalltalk-80 language, \
well-versed to scripting tasks and headless processing."

# 64-bit build currently segfaults, needs investigation
set_arch 32
set_builddir smalltalk-$VER

HARDLINK_TARGETS="
    opt/ooce/gnu-smalltalk/bin/gst-load
"

OPREFIX=$PREFIX
PREFIX+=/$PROG

reset_configure_opts

TESTSUITE_FILTER='^[A-Z#0-9 ][A-Z#0-9 ]'

# despite the fact that GNU smalltalk uses its own libtool
# there is a need for a ltdl.h header file, so require libtool
# GNU Smalltalk can be compiled --without-emacs but conceptually,
# it seems better to require it as the GNU smalltalk integrates with Emacs
BUILD_DEPENDS_IPS+="
    developer/build/libtool
    ooce/editor/emacs
"

# deliberately force emacs as dependency;
# GNU Smalltalk supports emacs and emacs as its IDE

RUN_DEPENDS_IPS+="
    ooce/editor/emacs
"

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

# disable-generational-gc because libsigsegv not found
CONFIGURE_OPTS+="
    --with-gmp
    --disable-generational-gc
    --with-emacs
    --with-lispdir=$OPREFIX/emacs/share/emacs/site-lisp
    --with-lispstartdir=$OPREFIX/emacs/share/emacs/site-lisp/site-start.d
"

# GNU Smalltalk does not find gmp headers
CPPFLAGS+=" -I/usr/include/gmp"
[ $RELVER -ge 151037 ] && LDFLAGS32+=" -lssp_ns"

# create package functions
init
download_source $PROG smalltalk $VER
patch_source
prep_build
build
strip_install
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
