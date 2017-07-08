#!/bin/sh

# This script generates a list of the dependencies for a full OmniOS
# build which can be used to update the omnios-build-tools meta package
# manifest.

dir=${1:-build}

if [ ! -x "$dir/buildctl" ]; then
	echo "Syntax: $0 <path to omnios-build tree>"
	exit 1
fi

find $dir -type f -name \*build\*.sh \
    -exec ggrep -A1 -h BUILD_DEPENDS_IPS {} + | sed -n '
	/=/ {
		# Remove quotes
		s/["'"'"']//g
		# Remove initial variable name
		s/.*=//
		# Remove variables from RHS
		s/\$[^ ]* *//g
		# Remove comments
		s/^ *#.*//
		# Remove specific versions
		s/@[^ ]* *//
		# Swap whitespace for = (tr will switch to newline)
		s/  */=/g
		# Skip lines now blank
		/^$/d
		p
	}
' | tr '=' '\n' | sort | uniq | sed '
	/^\//d
	/SUNWcs/d
	/^gcc[0-9]*$/d
	/^[0-9]/d
	/^auto/d
	/^omniti/d
	/^developer\/gcc44/d
	s/.*/depend fmri=& type=require/
'

