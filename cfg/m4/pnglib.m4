# **************************************************************************
# SIM_AC_HAVE_LIBPNG_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libpng
#   sim_ac_libpng_cppflags
#   sim_ac_libpng_ldflags
#   sim_ac_libpng_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBPNG_IFELSE],
[: ${sim_ac_have_libpng=false}
AC_MSG_CHECKING([for libpng])
AC_ARG_WITH(
  [png],
  [AC_HELP_STRING([--with-png=PATH], [enable/disable libpng support])],
  [case $withval in
  yes | "") sim_ac_want_libpng=true ;;
  no)       sim_ac_want_libpng=false ;;
  *)        sim_ac_want_libpng=true
            sim_ac_libpng_path=$withval ;;
  esac],
  [sim_ac_want_libpng=true])
case $sim_ac_want_libpng in
true)
  $sim_ac_have_libpng && break
  sim_ac_libpng_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libpng_save_LDFLAGS=$LDFLAGS
  sim_ac_libpng_save_LIBS=$LIBS
  sim_ac_libpng_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libpng_debug=true
  # test -z "$sim_ac_libpng_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libpng_path=$prefix
  sim_ac_libpng_name=png
  if test -n "$sim_ac_libpng_path"; then
    for sim_ac_libpng_candidate in \
      `( ls $sim_ac_libpng_path/lib/png*.lib;
         ls $sim_ac_libpng_path/lib/png*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libpng_candidate in
      *d.lib)
        $sim_ac_libpng_debug &&
          sim_ac_libpng_name=`basename $sim_ac_libpng_candidate .lib` ;;
      *.lib)
        sim_ac_libpng_name=`basename $sim_ac_libpng_candidate .lib` ;;
      esac
    done
    sim_ac_libpng_cppflags="-I$sim_ac_libpng_path/include"
    CPPFLAGS="$sim_ac_libpng_cppflags $CPPFLAGS"
    sim_ac_libpng_ldflags="-L$sim_ac_libpng_path/lib"
    LDFLAGS="$sim_ac_libpng_ldflags $LDFLAGS"
    # unset sim_ac_libpng_candidate
    # unset sim_ac_libpng_path
  fi
  sim_ac_libpng_libs="-l$sim_ac_libpng_name"
  LIBS="$sim_ac_libpng_libs $LIBS"
  AC_TRY_LINK(
    [#include <png.h>],
    [(void)png_read_info(0L, 0L);],
    [sim_ac_have_libpng=true])
  CPPFLAGS=$sim_ac_libpng_save_CPPFLAGS
  LDFLAGS=$sim_ac_libpng_save_LDFLAGS
  LIBS=$sim_ac_libpng_save_LIBS
  # unset sim_ac_libpng_debug
  # unset sim_ac_libpng_name
  # unset sim_ac_libpng_save_CPPFLAGS
  # unset sim_ac_libpng_save_LDFLAGS
  # unset sim_ac_libpng_save_LIBS
  ;;
esac
if $sim_ac_want_libpng; then
  if $sim_ac_have_libpng; then
    AC_MSG_RESULT([success ($sim_ac_libpng_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libpng
])

# **************************************************************************
# Usage:
#  SIM_AC_CHECK_PNG_READY([ACTION-IF-READY[, ACTION-IF-NOT-READY]])
#
#  Try to link code which needs the PNG development system.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_PNG_READY],
[AC_MSG_CHECKING([if we can use libpng without explicit linkage])
AC_TRY_LINK(
  [#include <png.h>],
  [(void)png_read_info(0L, 0L);],
  sim_ac_png_ready=true,
  sim_ac_png_ready=false)
if $sim_ac_png_ready; then
  AC_MSG_RESULT([yes])
  $1
else
  AC_MSG_RESULT([no])
  $2
fi
])

# EOF **********************************************************************
