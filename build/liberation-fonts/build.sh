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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=liberation-fonts
VER=2.1.1
PKG=ooce/fonts/liberation
SUMMARY="Liberation fonts"
DESC="A collection which aims to provide document layout compatibility "
DESC+="as usage of Times New Roman, Arial, Courier New."

SKIP_LICENCES=SILv1.1
set_builddir $PROG-ttf-$VER

copy_fonts() {
    dst=$DESTDIR$PREFIX/share/fonts/truetype/liberation

    logcmd mkdir -p $dst || logerr "--- mkdir failed"

    logmsg "--- copying fonts"
    logcmd cp $TMPDIR/$BUILDDIR/*.ttf $dst \
        || logerr "--- copying fonts failed"
}

init
download_source $PROG $BUILDDIR
patch_source
prep_build
copy_fonts
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
