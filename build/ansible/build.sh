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
# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=ansible
# NB: When bumping this version, also run this script with -P to re-generate
# files/constraints which fixes the version of dependant python modules for
# reproducible builds.
VER=9.1.0
PKG=ooce/system/management/ansible
SUMMARY="Radically simple IT automation"
DESC="Ansible is a radically simple IT automation system."

OPREFIX=$PREFIX
PREFIX+=/$PROG

# The pkg dependency checker does not find these in the virtual environment
PYMVER=${PYTHONVER:0:1}
RUN_DEPENDS_IPS+="
    runtime/python-$PYTHONPKGVER
    library/python-$PYMVER/pyyaml-$PYTHONPKGVER
    library/python-$PYMVER/cryptography-$PYTHONPKGVER
    library/python-$PYMVER/cffi-$PYTHONPKGVER
    library/python-$PYMVER/pycparser-$PYTHONPKGVER
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

licences() {
    # The ansible licence is not bundled with the pypi package
    logcmd -p curl -Ls \
        https://raw.githubusercontent.com/ansible/ansible/devel/COPYING \
        > $TMPDIR/COPYING || logerr "Licence retrieval failed"
}

init
prep_build
pyvenv_build $PROG $VER
licences
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
