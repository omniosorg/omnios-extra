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
# OmniOS package for the PARI/GP computer algebra system 
# Copyright 2025 David Stes
# NOTE: PARI from https://pari.math.u-bordeaux.fr is NOT covered by the OmniOS package copyright
# Files or logfiles derived from PARI are NOT covered by the OmniOS package copyright

. ../../lib/build.sh

PROG=pari
VER=2.17.3
PKG=ooce/library/math/pari
SUMMARY="PARI/GP"
DESC="Computer algebra system with the main aim of facilitating number theory computations"

OPREFIX=$PREFIX
PREFIX+=/$PROG

set_arch 64

# make target is gp
# check test target is dyntest-all
MAKE_TARGET=gp

# PARI/GP configure is not GNU autoconf
# set build style autoconf-like for prep-build
CONFIGURE_CMD=./Configure
# reset_configure_opts

# the PARI test script is in : src/test/dotest
# PARI measures with test-all diffs between static and dyn linked gp
# it prints timing information and checks for correctness
# the timing info could be useful but for our purpose remove/filter it from the testsuite.log
TESTSUITE_SED="
s/gp-sta..TIME=[ ]*[0-9]*//g
s/gp-dyn..TIME=[ ]*[0-9]*//g
/Total bench/d
"

# for dotest-env in testsuite
# if not set testsuite seems to report a bug and exit code nonzero
export AAA='XXX'
export BBB='YYY'

XFORM_ARGS="
    -DOPREFIX=${OPREFIX#/}
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

# build with GNU gmp
# could use an IPS mediator for selecting the native (non GNU gmp) arithmetic
# PARI/GP does not find gmp headers
# --with-gmp-lib=/usr/lib/amd64
CONFIGURE_OPTS[amd64]="
    --prefix=$PREFIX
    --bindir=$PREFIX/bin
    --libdir=$PREFIX/lib/$arch
    --with-readline
    --mt=pthread
    --with-gmp
    --with-gmp-include=/usr/include/gmp
"

LDFLAGS[i386]+=" -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -R$OPREFIX/lib/amd64"
LDFLAGS[i386]+=" -lssp_ns"

# create package functions
init
download_source $PROG $PROG $VER
patch_source
prep_build autoconf-like
build
strip_install
run_testsuite dyntest-all
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
