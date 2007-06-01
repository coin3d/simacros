#!/bin/sh

##
# Purpose: Convenience script to build the local bootstrap environment.
# Requirements: GNU tar, GNU make
#
# Author: Tamer Fahmy <tamer@sim.no>
# Date: 2006-05-29 on a nearly sunny day in Trondheim, Norway
# 

SIMACROSDIR="`pwd`/`dirname $0`/.."

if test ! -d $SIMACROSDIR/bootstrap; then
  echo "A directory named bootstrap/ needs to exist in the simacros root directory."
  echo "Please, ensure that this requirement is met and try again."
  echo
  exit 23
fi

if test ! -d $SIMACROSDIR/autotools; then
  echo "A directory named autotools/ containing the current autotools archives needs to exist in the simacros root directory."
  echo "Please, ensure that this requirement is met and try again."
  exit 46
fi

GMAKE="make"
if test -z "`make --version 2>/dev/null | grep GNU`"; then
  if test -z "`gmake --version 2>/dev/null | grep GNU`"; then
    echo "No GNU make version could be found. Bailing out..."
    exit 69
  else
    GMAKE="gmake"
  fi
fi

# add the local bootstrap binary
PATH=$SIMACROSDIR/bootstrap/bin:$PATH
export PATH

if test ! -d $SIMACROSDIR/bootstrap/sources; then
  mkdir $SIMACROSDIR/bootstrap/sources
fi

# extract and build autoconf, automake and libtool version
for archive in $SIMACROSDIR/autotools/*.tar.gz; do
  ARCHIVEDIR=$SIMACROSDIR/bootstrap/sources/`basename $archive .tar.gz`

  echo "=== Extracting $archive to $ARCHIVEDIR"
  tar xvzf $archive -C $SIMACROSDIR/bootstrap/sources/

  echo "=== Creating local bootstrap environment for $archive"
  cd $ARCHIVEDIR; ./configure --prefix=$SIMACROSDIR/bootstrap --disable-ltdl-install && $GMAKE && $GMAKE install
done

echo
echo "Your local bootstrap environment is ready."
echo
echo "You should now be able to conduct autotools bootstraps within
the root directory of your local Coin3D project repository checkout by
invoking the bootstrap script $SIMACROSDIR/bin/bootstrap."
echo
echo "Happy bootstrap'ing..."
