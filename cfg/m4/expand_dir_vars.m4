############################################################################
# Usage:
#   SIM_EXPAND_DIR_VARS
#
# Description:
#   Expand these variables into their correct full directory paths:
#    $prefix  $exec_prefix  $includedir  $libdir  $datadir
# 
# Author: Morten Eriksen, <mortene@sim.no>.
# 

AC_DEFUN([SIM_EXPAND_DIR_VARS], [
test x"$prefix" = x"NONE" && prefix="$ac_default_prefix"
test x"$exec_prefix" = x"NONE" && exec_prefix="${prefix}"

# This is the list of all install-path variables found in configure
# scripts. FIXME: use another "eval-nesting" to move assignments into
# a for-loop. 20000704 mortene.
bindir="`eval echo $bindir`"
sbindir="`eval echo $sbindir`"
libexecdir="`eval echo $libexecdir`"
datadir="`eval echo $datadir`"
sysconfdir="`eval echo $sysconfdir`"
sharedstatedir="`eval echo $sharedstatedir`"
localstatedir="`eval echo $localstatedir`"
libdir="`eval echo $libdir`"
includedir="`eval echo $includedir`"
infodir="`eval echo $infodir`"
mandir="`eval echo $mandir`"
])
