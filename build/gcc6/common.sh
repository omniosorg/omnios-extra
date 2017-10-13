
GCCMAJOR=6
GCCVER=6.4.0
OPT=/opt/gcc-$GCCMAJOR
PKGV=gcc$GCCMAJOR

XFORM_ARGS="-D MAJOR=$GCCMAJOR -D PKGV=$PKGV -D OPT=$OPT -D GCCVER=$GCCVER"

# Build gcc with itself
export LD_LIBRARY_PATH=$OPT/lib
export PATH=/usr/perl5/$PERLVER/bin:$OPT/bin:$PATH

# Use a dedicated temporary directory
# (avoids conflicts with other gcc versions during parallel builds)
export TMPDIR=$TMPDIR/gcc-$GCCMAJOR
export DTMPDIR=$TMPDIR

