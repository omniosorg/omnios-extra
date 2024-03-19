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

PROG=asciidoctor
VER=2.0.22
PKG=ooce/text/asciidoctor
SUMMARY="Toolchain for converting AsciiDoc to other formats"
DESC="A fast, open source text processor and publishing toolchain, "
DESC+="for converting AsciiDoc content to HTML 5, DocBook 5, and other formats"

set_rubyver
set_arch 64

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DPROG=$PROG
    -DVERSION=$VER
    -DRUBYVER=$RUBYVER
"

pre_configure() { false; }

make_arch() {
    logmsg "Building $PROG"
    logcmd gem build $PROG.gemspec || logerr "Build failed"
}

make_install() {
    logmsg "Installing $PROG"
    logcmd gem install $PROG-$VER.gem \
        --no-document \
        --build-root $DESTDIR \
        || logerr "Installation failed"
}

init
download_source $PROG v$VER
patch_source
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
