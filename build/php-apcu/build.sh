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

# Copyright 2026 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=php-apcu
VER=5.1.28
PKG=ooce/application/php-XX/apcu
SUMMARY="The APCu PHP extension"
DESC="APCu - an in-memory key-value store for PHP"

PHPVERSIONS="8.2 8.3 8.4 8.5"

set_arch 64
set_builddir apcu-$VER

SKIP_LICENCES=PHP
SKIP_RTIME_CHECK=1

init
prep_build

# Needs to be after prep_build which sets DESTDIR
MAKE_INSTALL_ARGS="
    INSTALL_ROOT=$DESTDIR
"

download_source $PROG apcu $VER
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
