#
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
# Copyright (c) 2015 by Delphix. All rights reserved.
# Copyright 2017 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2022 OmniOS Community Edition (OmniOSce) Association.
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
unset MAKEFLAGS
unset PKG_IMAGE

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

# This is here so that it can be overidden in site.sh
test_relver() {
    typeset op="${1:?op}"
    typeset ver="${2:?ver}"
    typeset testver="$RELVER"

    case "$op" in
        ">")    ((testver > ver)) ;;
        ">=")   ((testver >= ver)) ;;
        "<")    ((testver < ver)) ;;
        "<=")   ((testver <= ver)) ;;
        =|==)   ((testver == ver)) ;;
    esac
}

# Platform information, e.g. 5.11
SUNOSVER=`uname -r`

# Default branch
DASHREV=0
PVER=$RELVER.$DASHREV

DISTRO=OmniOS
DISTRO_LONG="OmniOS Community Edition"
HOMEURL=https://omnios.org
# Default package publisher
PKGPUBLISHER=extra.omnios

# Supported architectures, and the default set.
ARCH_LIST="i386 amd64 aarch64"
CROSS_ARCH="aarch64"
DEFAULT_ARCH="i386 amd64"
# NATIVE_ARCH is the native architecture, which is i386 even when we are
# building a package for amd64, or both i386 and amd64.
NATIVE_ARCH="i386"
BUILD_ARCH="amd64"

# Default repository
PKGSRVR=file://$ROOTDIR/tmp.repo/

# Use bash for subshells and commands launched by python setuptools
export SHELL=/usr/bin/bash

# The package publisher email address
PUBLISHER_EMAIL=sa@omnios.org

# The github repository root from which some packages are pulled
GITHUB=https://github.com
GITHUBAPI=https://api.github.com
OOCEGITHUB=$GITHUB/omniosorg
# The main OOCE mirror
SRCMIRROR=https://mirrors.omnios.org

# The server or path from which to fetch source code and other files.
# MIRROR may be overridden in lib/site.sh but defaults to the main OOCE mirror
# If $MIRROR begins with a '/', it is treated as a local directory.
MIRROR=$SRCMIRROR

# The production IPS repository for this branch (may be overridden in site.sh)
# Used for package contents diffing.
if [ $((RELVER % 2)) == 0 ]; then
    IPS_REPO=https://pkg.omnios.org/r$RELVER/extra
    OB_IPS_REPO=https://pkg.omnios.org/r$RELVER/core
else
    IPS_REPO=https://pkg.omnios.org/bloody/extra
    OB_IPS_REPO=https://pkg.omnios.org/bloody/core
fi
BRAICH_REPO=https://pkg.omnios.org/bloody/braich

ARCHIVE_TYPES="tar.zst tar.xz tar.bz2 tar.lz tar.gz tgz tar zip 7z"

# Default prefix for packages (may be overridden)
PREFIX=/opt/ooce
NOTES_LOCATION=$PREFIX/share/doc/release-notes
CROSSTOOLS=/opt/cross

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

typeset -A TRIPLETS=(
    [i386]=i386-pc-solaris2.11
    [amd64]=x86_64-pc-solaris2.11
    [aarch64]=aarch64-unknown-solaris2.11
)

typeset -A RUSTTRIPLETS=(
    [amd64]=x86_64-unknown-illumos
    [aarch64]=aarch64-unknown-illumos
)

#############################################################################
# Perl stuff
#############################################################################

# Perl versions we currently build against
PERLVER=`perl -MConfig -e 'print $Config{version}'`
SPERLVER=${PERLVER%.*}

# Full paths to bins
PERL=/usr/perl5/${SPERLVER}/bin/perl

# Default Makefile.PL options
PERL_MAKEFILE_OPTS="INSTALLSITEBIN=$PREFIX/perl5/bin \
                    INSTALLSITESCRIPT=$PREFIX/perl5/bin \
                    INSTALLSITEMAN1DIR=$PREFIX/perl5/$SPERLVER/man/man1 \
                    INSTALLSITEMAN3DIR=$PREFIX/perl5/$SPERLVER/man/man3 \
                    INSTALLDIRS=site"

# Accept MakeMaker defaults so as not to stall build scripts
export PERL_MM_USE_DEFAULT=true

# When building perl modules, run make test
# Unset in a build script to skip tests
PERL_MAKE_TEST=1

#############################################################################
# Paths to common tools
#############################################################################
USRBIN=/usr/bin
USRHASBIN=/usr/has/bin
OOCEOPT=/opt/ooce
OOCEBIN=$OOCEOPT/bin
SFWBIN=/usr/sfw/bin
ONBLDBIN=/opt/onbld/bin
GNUBIN=/usr/gnu/bin

# Define variables for standard utilities so that we can choose to run the
# native version even if a build script modifies the path to put GNUBIN first.
for util in \
    basename cat comm cut diff dis tput digest mktemp sort sed tee rm mv cp \
    mkdir rmdir readlink ln ls chmod touch grep time find fgrep egrep uniq \
    stat strip sleep tail date
do
    declare -n _var=${util^^}
    declare -g _var=$USRBIN/$util
    unset -vn _var
done

AR=$USRBIN/ar
CURL=$USRBIN/curl
ELFEDIT=$USRBIN/elfedit
if test_relver '>=' 151053; then
    FILE=$USRHASBIN/file
else
    FILE=$USRBIN/file
fi
GIT=$USRBIN/git
LZIP=$USRBIN/lzip
NAWK=$USRBIN/awk
RSYNC=$USRBIN/rsync
SEVENZ=$USRBIN/7zz
UNZIP=$USRBIN/unzip
WGET=$USRBIN/wget
XZCAT=$USRBIN/xzcat
ZSTD=$USRBIN/zstd

# GNU utilities
AWK=$GNUBIN/awk
MAKE=$GNUBIN/make
TESTSUITE_MAKE="$MAKE"
GDIFF=$GNUBIN/diff
PATCH=$GNUBIN/patch
REALPATH=$GNUBIN/realpath
TAR="$GNUBIN/tar --no-same-permissions --no-same-owner"

# Command for privilege escalation. Can be overridden in site.sh
PFEXEC=$USRBIN/sudo

# pkg(7) commands
PKGCLIENT=$USRBIN/pkg
PKGDEPEND=$USRBIN/pkgdepend
PKGFMT=$USRBIN/pkgfmt
PKGLINT=$USRBIN/pkglint
PKGMOGRIFY=$USRBIN/pkgmogrify
PKGMERGE=$USRBIN/pkgmerge
PKGRECV=$USRBIN/pkgrecv
PKGREPO=$USRBIN/pkgrepo
PKGSEND=$USRBIN/pkgsend

# Utilities that come from omnios-extra
BUNZIP2=$OOCEBIN/pbunzip2
CARGO=$OOCEBIN/cargo
CMAKE=$OOCEBIN/cmake
FD=$OOCEBIN/fd
GZIP=$OOCEBIN/pigz
JQ=$OOCEBIN/jq
NINJA=$OOCEBIN/ninja
GYP=$OOCEBIN/gyp
RIPGREP=$OOCEBIN/rg

FIND_ELF=$ONBLDBIN/find_elf
CHECK_RTIME=$ONBLDBIN/check_rtime
CTFDUMP=$ONBLDBIN/i386/ctfdump
CTFCONVERT=$ONBLDBIN/i386/ctfconvert
CTFSTABS=$ONBLDBIN/i386/ctfstabs
CW=$ONBLDBIN/i386/cw
GENOFFSETS=$ONBLDBIN/genoffsets
CTF_FLAGS=
typeset -A CTFCFLAGS
CTFCFLAGS[_]="-gstrict-dwarf"
CTFCFLAGS[10]="-gdwarf-2"
CTFCFLAGS[11]="-gdwarf-2"
CTFCFLAGS[12]="-gdwarf-2"
CTFCFLAGS[13]="-gdwarf-2"
CTFCFLAGS[14]="-gdwarf-4"
GENOFFSETS_CFLAGS="
    ${CTFCFLAGS[_]}
    -_gcc=-fno-eliminate-unused-debug-symbols
    -_gcc=-fno-eliminate-unused-debug-types
"

test_relver '>=' 151053 && GENOFFSETS_CFLAGS+=" -std=gnu99"

CTF_DEFAULT=1

# Figure out number of logical CPUs for use with parallel gmake jobs (-j)
# Default to 1.5*nCPUs as we assume the build machine is 100% devoted to
# compiling.
# A build script may serialize make by setting NO_PARALLEL_MAKE
LCPUS=`psrinfo | wc -l`
MJOBS="$[ $LCPUS + ($LCPUS / 2) ]"
[ "$MJOBS" = "0" ] && MJOBS=2
MAKE_JOBS="-j $MJOBS"
MAKE_TARGET=

# Remove install or packaging files by default. You can set this in a build
# script when testing to speed up building a package
DONT_REMOVE_INSTALL_DIR=

SYS_XFORM_ARGS=
XFORM_ARGS=

# Prior to release r151040, some users and groups were provided as part of the
# default system passwd file and they were used by packages. Those packages
# did not provide user or group actions for these since they were present in
# every system by default.
# As of r151040, the default system files under /etc do not include these users
# and groups; packages must now provide them. We don't want to provide them
# on previous releases though as downgrading a package to a version prior to
# this change will result in the users being removed. Any systems being
# upgraded to r151040 from a previous release will keep the users and then
# a package update will overwrite them. Since the users are included in the
# earliest available package for r151040, it should not be possible for anyone
# to downgrade and shoot themselves in the foot.
if test_relver '>=' 151040; then
    SYS_XFORM_ARGS+=" -DGATE_SYSUSER="
else
    SYS_XFORM_ARGS+=" -DGATE_SYSUSER=#"
fi

PKG_INCLUDE_TS=

#############################################################################
# C compiler options - these can be overridden by a build script
#############################################################################

# The list of options which define the build environment
BUILDENV_OPTS="
    CONFIGURE_CMD CONFIGURE_OPTS
    CFLAGS CXXFLAGS CPPFLAGS
    LDFLAGS
    MAKE_JOBS
"

CCACHE_PATH=/opt/ooce/ccache/bin

# We (almost) always want GCC
CC=gcc
CXX=g++

# Specify default GCC version for building packages
case $RELVER in
    15102[12])          DEFAULT_GCC_VER=5.1.0; ILLUMOS_GCC_VER=4.4.4 ;;
    15102[34])          DEFAULT_GCC_VER=5 ;;
    15102[56])          DEFAULT_GCC_VER=6 ;;
    15102[78])          DEFAULT_GCC_VER=7 ;;
    151029|151030)      DEFAULT_GCC_VER=8; ILLUMOS_GCC_VER=4.4.4 ;;
    15103[12])          DEFAULT_GCC_VER=8; ILLUMOS_GCC_VER=7 ;;
    15103[34])          DEFAULT_GCC_VER=9; ILLUMOS_GCC_VER=7 ;;
    15103[5-8])         DEFAULT_GCC_VER=10; ILLUMOS_GCC_VER=7 ;;
    151039|151040)      DEFAULT_GCC_VER=11; ILLUMOS_GCC_VER=7 ;;
    15104[12])          DEFAULT_GCC_VER=11; ILLUMOS_GCC_VER=10 ;;
    15104[3-6])         DEFAULT_GCC_VER=12; ILLUMOS_GCC_VER=10 ;;
    15104[7-9]|151050)  DEFAULT_GCC_VER=13; ILLUMOS_GCC_VER=10 ;;
    15105[1-9])         DEFAULT_GCC_VER=14; ILLUMOS_GCC_VER=10 ;;
    *) logerr "Unknown release '$RELVER', can't select compiler." ;;
esac

# Specify default clang version for building packages
case $RELVER in
    15104[3-4])         DEFAULT_CLANG_VER=14 ;;
    15104[5-6])         DEFAULT_CLANG_VER=15 ;;
    15104[7-8])         DEFAULT_CLANG_VER=16 ;;
    151049|151050)      DEFAULT_CLANG_VER=17 ;;
    15105[1-2])         DEFAULT_CLANG_VER=18 ;;
    15105[3-9])         DEFAULT_CLANG_VER=19 ;;
    *)                  DEFAULT_CLANG_VER=13 ;;
esac

DEFAULT_GO_VER=1.23
DEFAULT_NODE_VER=20
DEFAULT_RUBY_VER=3.3
DEFAULT_ZIG_VER=0.12

PYTHON2VER=2.7
case $RELVER in
    15103[3-6])         PYTHON3VER=3.7 ;;
    15103[7-9])         PYTHON3VER=3.9 ;;
    151040)             PYTHON3VER=3.9 ;;
    15104[1-4])         PYTHON3VER=3.10 ;;
    15104[5-8])         PYTHON3VER=3.11 ;;
    151049|15105[0-2])  PYTHON3VER=3.12 ;;
    15105[3-9])         PYTHON3VER=3.13 ;;
    *)                  PYTHON3VER=3.5 ;;
esac
# Specify default Python version for building packages
DEFAULT_PYTHON_VER=$PYTHON3VER

# Specify expected openssl mediator setting
if test_relver '>=' 151041; then
    EXP_OPENSSLVER=3
else
    EXP_OPENSSLVER=1.1
fi

# Default database versions to bundle into packages which use the libraries
PGSQLVER=14
MARIASQLVER=10.6

# Options to turn compiler features on and off. Associative array keyed by
# compiler version or _ for all versions.
typeset -A FCFLAGS

# Use optimisation level 2 with all versions of gcc
FCFLAGS[_]+=" -O2"

# We generally want to keep the frame pointer around, regardless of the
# optimisation level - we like stack traces too much and it is of questionable
# benefit anyway, even on i386.
FCFLAGS[_]+=" -fno-omit-frame-pointer"

# Taken from illumos-joyent along with the following comment:
# "gcc has a rather aggressive optimization on by default that infers loop
#  bounds based on undefined behaviour (!!).  This can lead to some VERY
#  surprising optimisations -- ones that may be technically correct in the
#  strictest sense but also result in incorrect program behaviour."
FCFLAGS[7]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[8]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[9]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[10]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[11]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[12]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[13]+=" -fno-aggressive-loop-optimizations"
FCFLAGS[14]+=" -fno-aggressive-loop-optimizations"

# Flags to enable particular standards; see standards(7)
typeset -A STANDARDS

STANDARDS[POSIX]="-D_POSIX_C_SOURCE=200112L -D_POSIX_PTHREAD_SEMANTICS"
STANDARDS[POSIX+EXTENSIONS]="${STANDARDS[POSIX]} -D__EXTENSIONS__=1"
STANDARDS[XPG3]="-D_XOPEN_SOURCE"
STANDARDS[XPG4]="-D_XOPEN_SOURCE -D_XOPEN_VERSION=4"
STANDARDS[XPG4v2]="-D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED=1"
STANDARDS[XPG5]="-D_XOPEN_SOURCE=500 -D__EXTENSIONS__=1"
STANDARDS[XPG6]="-D_XOPEN_SOURCE=600 -D__EXTENSIONS__=1"
STANDARDS[XPG7]="-D_XOPEN_SOURCE=700 -D__EXTENSIONS__=1"
STANDARDS[XPG8]="-D_XOPEN_SOURCE=800 -D__EXTENSIONS__=1"

typeset -A CFLAGS=(
    [i386]=-m32
    [amd64]=-m64
)

typeset -A LDFLAGS=(
    [i386]=-m32
    [amd64]=-m64
)

typeset -A CXXFLAGS=(
    [i386]=-m32
    [amd64]=-m64
)

typeset -A PYBUILDOPTS=()
typeset -A PYINSTOPTS=()

typeset -A CPPFLAGS=()
typeset -A PKG_CONFIG_PATH=(
    [i386]=$PREFIX/lib/pkgconfig
    [amd64]=$PREFIX/lib/amd64/pkgconfig
)

typeset -A LIBDIRS=(
    [i386]=lib
    [amd64]=lib/amd64
    [aarch64]=lib
)

MAKE_ARGS=
MAKE_ARGS_WS=
MAKE_INSTALL_TARGET=install
MAKE_INSTALL_ARGS=
MAKE_INSTALL_ARGS_WS=
MAKE_INSTALL_ARGS_32=
MAKE_INSTALL_ARGS_64=
NO_PARALLEL_MAKE=
MAKE_TESTSUITE_ARGS=--quiet
MAKE_TESTSUITE_ARGS_WS=

DESTDIR=

#############################################################################
# Flags for building kernel modules
#############################################################################

CFLAGS[kmod_amd64]="
    -mcmodel=kernel
    -fno-strict-aliasing -fno-unit-at-a-time
    -fno-optimize-sibling-calls -ffreestanding -mno-red-zone
    -mno-mmx -mno-sse -msave-args
    -Winline -fno-inline-small-functions -fno-inline-functions-called-once
    -fno-ipa-cp -fno-ipa-icf -fno-clone-functions -fno-reorder-functions
    -fno-reorder-blocks-and-partition
    --param=max-inline-insns-single=450 -fno-shrink-wrap
    -mindirect-branch=thunk-extern -mindirect-branch-register
    -fno-asynchronous-unwind-tables -fstack-protector-strong
"
LDFLAGS[kmod_amd64]="-ztype=kmod"

CFLAGS[kmod_aarch64]="
    -mcmodel=large
    -fno-strict-aliasing -fno-unit-at-a-time
    -fno-optimize-sibling-calls -ffreestanding -msave-args
    -mgeneral-regs-only -mstrict-align -mtls-dialect=trad
    -Winline -fno-inline-small-functions -fno-inline-functions-called-once
    -fno-ipa-cp -fno-ipa-icf -fno-clone-functions -fno-reorder-functions
    -fno-reorder-blocks-and-partition
    --param=max-inline-insns-single=450 -fno-shrink-wrap
    -fno-asynchronous-unwind-tables -fstack-protector-strong
"
LDFLAGS[kmod_aarch64]="-ztype=kmod"

#############################################################################
# Configuration of the packaged software
#############################################################################

CONFIGURE_CMD="./configure"

# Configure options to apply to both builds - this is the one you usually want
# to change for things like --enable-feature
typeset -A CONFIGURE_OPTS=()
FORGO_ISAEXEC=

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
