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

# Copyright 2024 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=atuin
VER=18.4.0
PKG=ooce/util/atuin
SUMMARY="Magical shell history"
DESC="Replaces your existing shell history with a SQLite database and "
DESC+="records additional context for your commands. Additionally, "
DESC+="it provides optional and fully encrypted synchronisation of "
DESC+="your history between machines, via an Atuin server."

BMI_EXPECTED=1

BUILD_DEPENDS_IPS="
    ooce/developer/rust
"

set_arch 64

export PROTOC_INCLUDE="$PREFIX/include"

init
download_source $PROG v$VER
patch_source
prep_build
build_rust
install_rust
strip_install
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
