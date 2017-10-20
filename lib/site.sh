# Package server URL and publisher
: ${PKGPUBLISHER:=omnios}
: ${PKGSRVR:=file://$MYDIR/../tmp.repo/}

# To create a on-disk repo in the top level of your checkout
# and publish there instead of the URI specified above.
#
#PKGSRVR=file://$MYDIR/../tmp.repo/

# Uncommenting this line will use a pre-built illumos-omnios, instead of having
# us build it.  NOTE: A build of illumos-omnios can be launched concurrently in
# conjunction with setting this variable. See functions.sh:wait_for_prebuilt().
#PREBUILT_ILLUMOS=$HOME/build/prebuild

