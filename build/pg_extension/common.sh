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

# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.

PGVERSIONS="13 14 15"

for v in $PGVERSIONS; do
    BUILD_DEPENDS_IPS+=" ooce/library/postgresql-$v"
done
DEF_RUN_DEPENDS_IPS="ooce/database/postgresql-XX"

set_arch 64
# building the extensions should use the same llvm/clang version that was
# used to build postgres JIT code; however part of the build uses
# the first unversioned binary found in the PATH
set_clangver
BASEPATH=$PATH set_gccver $DEFAULT_GCC_VER

OPREFIX=$PREFIX
OPATH=$PATH

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
