# SIM_AC_CREATE_RECONFIGURE
#
# This macro creates a script called "reconfigure" in builldir that can be
# run instead of writing all the command line options you need all over
# again the next time you need to run configure.

AC_DEFUN([SIM_AC_CREATE_RECONFIGURE], [
# **************************************************************************
# create "reconfigure" script for invoking configure again with the exact
# same command line options as last time.
cat >reconfigure <<END_OF_SCRIPT
#! /bin/sh
echo $[0] $[@]
$[0] $[@]
END_OF_SCRIPT
chmod 755 reconfigure
])

