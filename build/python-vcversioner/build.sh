#!/usr/bin/bash

# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# Copyright 2017 OmniOS Community Edition (OmniOSce) Association.

# Load support functions
. ../../lib/functions.sh

PROG=vcversioner
VER=2.16.0.0
SUMMARY="Use version control tags to discover version numbers"
DESC="$SUMMARY"

XFORM_ARGS="-D PYTHONVER=$PYTHONVER"
PKG=library/python-2/vcversioner-27
RUN_DEPENDS_IPS="runtime/python-27"
init
download_source $PROG $PROG $VER
patch_source
prep_build
python_build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:
