#
# {{{ CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END }}}
#
# Copyright (c) 2015 by Delphix. All rights reserved.
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
#############################################################################
# Configuration for the build system
#############################################################################

# Clear environment variables we know to be bad for the build
unset LD_OPTIONS
unset LD_AUDIT LD_AUDIT_32 LD_AUDIT_64
unset LD_BIND_NOW LD_BIND_NOW_32 LD_BIND_NOW_64
unset LD_BREADTH LD_BREADTH_32 LD_BREADTH_64
unset LD_CONFIG LD_CONFIG_32 LD_CONFIG_64
unset LD_DEBUG LD_DEBUG_32 LD_DEBUG_64
unset LD_DEMANGLE LD_DEMANGLE_32 LD_DEMANGLE_64
unset LD_FLAGS LD_FLAGS_32 LD_FLAGS_64
unset LD_LIBRARY_PATH LD_LIBRARY_PATH_32 LD_LIBRARY_PATH_64
unset LD_LOADFLTR LD_LOADFLTR_32 LD_LOADFLTR_64
unset LD_NOAUDIT LD_NOAUDIT_32 LD_NOAUDIT_64
unset LD_NOAUXFLTR LD_NOAUXFLTR_32 LD_NOAUXFLTR_64
unset LD_NOCONFIG LD_NOCONFIG_32 LD_NOCONFIG_64
unset LD_NODIRCONFIG LD_NODIRCONFIG_32 LD_NODIRCONFIG_64
unset LD_NODIRECT LD_NODIRECT_32 LD_NODIRECT_64
unset LD_NOLAZYLOAD LD_NOLAZYLOAD_32 LD_NOLAZYLOAD_64
unset LD_NOOBJALTER LD_NOOBJALTER_32 LD_NOOBJALTER_64
unset LD_NOVERSION LD_NOVERSION_32 LD_NOVERSION_64
unset LD_ORIGIN LD_ORIGIN_32 LD_ORIGIN_64
unset LD_PRELOAD LD_PRELOAD_32 LD_PRELOAD_64
unset LD_PROFILE LD_PROFILE_32 LD_PROFILE_64
unset CFLAGS CPPFLAGS

unset CONFIG GROUP OWNER REMOTE ENV ARCH CLASSPATH NAME

# set locale to C
#
LANG=C;         export LANG
LC_ALL=C;       export LC_ALL
LC_COLLATE=C;   export LC_COLLATE
LC_CTYPE=C;     export LC_CTYPE
LC_MESSAGES=C;  export LC_MESSAGES
LC_MONETARY=C;  export LC_MONETARY
LC_NUMERIC=C;   export LC_NUMERIC
LC_TIME=C;      export LC_TIME

######################################################################

# Determine release version based on build system
if [[ "`uname -v`" != omnios-* ]]; then
	echo "This does not appear to be an OmniOS system."
    uname -v
    exit 1
fi
RELVER="`head -1 /etc/release | awk '{print $3}' | sed 's/[a-z]//g'`"
if [[ ! "$RELVER" =~ ^151[0-9]{3}$ ]]; then
    echo "Unable to determine release version (got $RELVER)"
    exit 1
fi

# Default branch
DASHREV=0
[ $RELVER -ge 151027 ] && PVER=$RELVER.$DASHREV || PVER=$DASHREV.$RELVER

# Default package publisher
PKGPUBLISHER=extra.omnios

# Default repository
PKGSRVR=file://$ROOTDIR/tmp.repo/

# Use bash for subshells and commands launched by python setuptools
export SHELL=/usr/bin/bash

# The package publisher email address
PUBLISHER_EMAIL=sa@omniosce.org

# The github repository root from which some packages are pulled
GITHUB=https://github.com/omniosorg
# The main OOCE mirror
OOCEMIRROR=https://mirrors.omniosce.org

# The server or path from which to fetch source code and other files.
# MIRROR may be overridden in lib/site.sh but defaults to the main OOCE mirror
# If $MIRROR begins with a '/', it is treated as a local directory.
MIRROR=$OOCEMIRROR

# The production IPS repository for this branch (may be overriden in site.sh)
# Used for package contents diffing.
IPS_REPO=https://pkg.omniosce.org/r$RELVER/extra
[ $((RELVER % 2)) != 0 ] && IPS_REPO=https://pkg.omniosce.org/bloody/extra

ARCHIVE_TYPES="tar.xz tar.bz2 tar.gz tgz tar zip"

# Default prefix for packages (may be overridden)
PREFIX=/opt/ooce

# Temporary directories
# TMPDIR is used for source archives and build directories
#    to avoid collision on shared build systems,
#    TMPDIR includes a username
# DTMPDIR is used for constructing the DESTDIR path
# Let the environment override TMPDIR.
[ -z "$TMPDIR" ] && TMPDIR=/tmp/build_$USER
DTMPDIR=$TMPDIR

# Log file for all output
LOGFILE=$PWD/build.log

# Default patches dir
PATCHDIR=patches

# Do we create isaexec stubs for scripts and other non-binaries (default yes)
NOSCRIPTSTUB=

#############################################################################
# Perl stuff
#############################################################################

# Perl versions we currently build against
PERLVER="`perl -V:version | cut -d"'" -f2`"
SPERLVER=${PERLVER%.*}

# Full paths to bins
PERL32=/usr/perl5/${SPERLVER}/bin/$ISAPART/perl
PERL64=/usr/perl5/${SPERLVER}/bin/$ISAPART64/perl

# Default Makefile.PL options
PERL_MAKEFILE_OPTS="INSTALLSITEBIN=$PREFIX/bin/_ARCHBIN_ \
                    INSTALLSITESCRIPT=$PREFIX/bin/_ARCHBIN_ \
                    INSTALLSITEMAN1DIR=$PREFIX/share/man/man1 \
                    INSTALLSITEMAN3DIR=$PREFIX/share/man/man3 \
                    INSTALLDIRS=site"

# Accept MakeMaker defaults so as not to stall build scripts
export PERL_MM_USE_DEFAULT=true

# When building perl modules, run make test
# Unset in a build script to skip tests
PERL_MAKE_TEST=1

#############################################################################
# Python -- NOTE, these can be changed at runtime via set_python_version().
#############################################################################
: ${PYTHONVER:=2.7}
: ${PYTHONPKGVER:=${PYTHONVER//./}}
PYTHONPATH=/usr
PYTHON=$PYTHONPATH/bin/python$PYTHONVER
PYTHONLIB=$PYTHONPATH/lib

#############################################################################
# Paths to common tools
#############################################################################
WGET=wget
PATCH=gpatch
MAKE=gmake
TAR="gtar --no-same-permissions --no-same-owner"
GZIP=gzip
BUNZIP2=bunzip2
XZCAT=xzcat
UNZIP=unzip
AWK=gawk
GIT=git
RIPGREP=/opt/ooce/bin/rg
CMAKE=/opt/ooce/bin/cmake
# Command for privilege escalation. Can be overridden in site.sh
PFEXEC=sudo

PKGSEND=/usr/bin/pkgsend
PKGLINT=/usr/bin/pkglint
PKGMOGRIFY=/usr/bin/pkgmogrify
PKGFMT=/usr/bin/pkgfmt
PKGDEPEND=/usr/bin/pkgdepend

# Figure out number of logical CPUs for use with parallel gmake jobs (-j)
# Default to 1.5*nCPUs as we assume the build machine is 100% devoted to
# compiling.
# A build script may serialize make by setting NO_PARALLEL_MAKE
LCPUS=`psrinfo | wc -l`
MJOBS="$[ $LCPUS + ($LCPUS / 2) ]"
[ "$MJOBS" = "0" ] && MJOBS=2
MAKE_JOBS="-j $MJOBS"
MAKE_ARGS=
MAKE_INSTALL_ARGS=
MAKE_INSTALL_ARGS_32=
MAKE_INSTALL_ARGS_64=
NO_PARALLEL_MAKE=

# Remove install or packaging files by default. You can set this in a build
# script when testing to speed up building a package
DONT_REMOVE_INSTALL_DIR=

#############################################################################
# C compiler options - these can be overriden by a build script
#############################################################################
# isaexec(3C) variants
# These variables will be passed to the build to construct multi-arch
# binary and lib directories in DESTDIR

CCACHE_PATH=/opt/ooce/ccache/bin

ISAPART=i386
ISAPART64=amd64
BUILDORDER="32 64"

# For OmniOS we (almost) always want GCC
CC=gcc
CXX=g++

# Specify default GCC version for building packages
case $RELVER in
    15102[12])      DEFAULT_GCC_VER=5.1.0 ;;
    15102[34])      DEFAULT_GCC_VER=5 ;;
    15102[56])      DEFAULT_GCC_VER=6 ;;
    15102[78])      DEFAULT_GCC_VER=7 ;;
    151029|151030)  DEFAULT_GCC_VER=8 ;;
    *) logerr "Unknown release '$RELVER', can't select compiler." ;;
esac

# CFLAGS applies to both builds, 32/64 only gets applied to the respective
# build
CFLAGS="-O2"
CFLAGS32=
CFLAGS64="-m64"

# Linker flags
LDFLAGS=
LDFLAGS32=
LDFLAGS64="-m64"

# C pre-processor flags
CPPFLAGS=
CPPFLAGS32=
CPPFLAGS64=

# C++ flags
CXXFLAGS="-O2"
CXXFLAGS32=
CXXFLAGS64="-m64"

#############################################################################
# Configuration of the packaged software
#############################################################################
# Default configure command - almost always sufficient
CONFIGURE_CMD="./configure"

# Configure options to apply to both builds - this is the one you usually want
# to change for things like --enable-feature
CONFIGURE_OPTS=
CONFIGURE_OPTS_32=
CONFIGURE_OPTS_64=
# Configure options that can contain embedded white-space within escaped quotes
CONFIGURE_OPTS_WS=
CONFIGURE_OPTS_WS_32=
CONFIGURE_OPTS_WS_64=
FORGO_ISAEXEC=

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
