# **************************************************************************
# SIM_AC_HAVE_LIBZLIB_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libzlib
#   sim_ac_zlib_cppflags
#   sim_ac_zlib_ldflags
#   sim_ac_zlib_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBZLIB_IFELSE],
[: ${sim_ac_have_libzlib=false}
AC_MSG_CHECKING([for zlib])
AC_ARG_WITH(
  [zlib],
  [AC_HELP_STRING([--with-zlib=PATH], [enable/disable zlib support])],
  [case $withval in
  yes | "") sim_ac_want_libzlib=true ;;
  no)       sim_ac_want_libzlib=false ;;
  *)        sim_ac_want_libzlib=true
            sim_ac_libzlib_path=$withval ;;
  esac],
  [sim_ac_want_libzlib=true])
case $sim_ac_want_libzlib in
true)
  $sim_ac_have_libzlib && break
  sim_ac_libzlib_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libzlib_save_LDFLAGS=$LDFLAGS
  sim_ac_libzlib_save_LIBS=$LIBS
  sim_ac_libzlib_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libzlib_debug=true
  # test -z "$sim_ac_libzlib_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libzlib_path=$prefix
  sim_ac_libzlib_name=z
  if test -n "$sim_ac_libzlib_path"; then
    for sim_ac_libzlib_candidate in \
      `( ls $sim_ac_libzlib_path/lib/zlib*.lib;
         ls $sim_ac_libzlib_path/lib/zlib*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libzlib_candidate in
      *d.lib)
        $sim_ac_libzlib_debug &&
          sim_ac_libzlib_name=`basename $sim_ac_libzlib_candidate .lib` ;;
      *.lib)
        sim_ac_libzlib_name=`basename $sim_ac_libzlib_candidate .lib` ;;
      esac
    done
    sim_ac_libzlib_cppflags="-I$sim_ac_libzlib_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libzlib_cppflags"
    sim_ac_libzlib_ldflags="-L$sim_ac_libzlib_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libzlib_ldflags"
    # unset sim_ac_libzlib_candidate
    # unset sim_ac_libzlib_path
  fi
  sim_ac_libzlib_libs="-l$sim_ac_libzlib_name"
  LIBS="$sim_ac_libzlib_libs $LIBS"
  AC_TRY_LINK(
    [#include <zlib.h>],
    [(void)zlibVersion();],
    [sim_ac_have_libzlib=true])
  CPPFLAGS=$sim_ac_libzlib_save_CPPFLAGS
  LDFLAGS=$sim_ac_libzlib_save_LDFLAGS
  LIBS=$sim_ac_libzlib_save_LIBS
  # unset sim_ac_libzlib_debug
  # unset sim_ac_libzlib_name
  # unset sim_ac_libzlib_save_CPPFLAGS
  # unset sim_ac_libzlib_save_LDFLAGS
  # unset sim_ac_libzlib_save_LIBS
  ;;
esac
if $sim_ac_want_libzlib; then
  if $sim_ac_have_libzlib; then
    AC_MSG_RESULT([success ($sim_ac_libzlib_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libzlib
])

############################################################################
# Usage:
#  SIM_AC_CHECK_ZLIB_READY([ACTION-IF-READY[, ACTION-IF-NOT-READY]])
#
#  Try to link code which needs the ZLIB development system.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_ZLIB_READY], [
AC_MSG_CHECKING([if we can use zlib without explicit linkage])
sim_ac_zlib_ready=false
AC_TRY_LINK(
  [#include <zlib.h>],
  [(void)zlibVersion();],
  [sim_ac_zlib_ready=true])
if $sim_ac_zlib_ready; then
  AC_MSG_RESULT([yes])
  $1
else
  AC_MSG_RESULT([no])
  $2
fi
# unset sim_ac_zlib_ready
])

# EOF **********************************************************************
