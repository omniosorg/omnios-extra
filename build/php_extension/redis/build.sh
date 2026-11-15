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

. ../../../lib/build.sh

PROG=php-redis
VER=6.3.0
PKG=ooce/application/php-XX/redis
SUMMARY="The phpredis PHP extension"
DESC="phpredis - a PHP extension for Redis and compatible servers"

. $SRCDIR/../common.sh

set_builddir redis-$VER

init
prep_build
download_source $PROG redis $VER
patch_source
build_php_extension
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
