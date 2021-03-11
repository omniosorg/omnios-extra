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

PROG=php-imagick
VER=3.4.4
PKG=ooce/application/php-XX/imagick
SUMMARY="The Imagick PHP extension"
DESC="The Imagick PHP extension"

PHPVERSIONS="7.3 7.4"

# The ImageMagick ABI changes frequently. Lock the version
# pulled into each build of php-imagick.
IMGKVER=`pkg_ver imagemagick`
IMGKVER=${IMGKVER//-/.}
BUILD_DEPENDS_IPS="=ooce/application/imagemagick@$IMGKVER"
RUN_DEPENDS_IPS="$BUILD_DEPENDS_IPS"

set_arch 64
set_builddir imagick-$VER

SKIP_LICENCES=PHP
SKIP_RTIME_CHECK=1

CONFIGURE_OPTS_64="
    --with-imagick=$PREFIX/ImageMagick
"

init
prep_build

# Needs to be after prep_build which sets DESTDIR
MAKE_INSTALL_ARGS="
    INSTALL_ROOT=$DESTDIR
"

download_source $PROG $VER
patch_source

for p in $PHPVERSIONS; do
    [ -n "$FLAVOR" -a "$FLAVOR" != $p ] && continue
    note -n "Building For PHP $p"
    run_inbuild $PREFIX/php-$p/bin/phpize --clean
    logcmd rm -rf $DESTDIR/$PREFIX/
    run_inbuild $PREFIX/php-$p/bin/phpize
    PATH="$PREFIX/php-$p/bin:$PATH" build
    strip_install
    PKG=${PKG/XX/${p//./}} \
        RUN_DEPENDS_IPS+=" ${PKG%/*}" \
        DESC+=" $p" \
        make_package
done

clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
