# **************************************************************************
# SIM_AC_HAVE_LIBTIFF_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libtiff
#   sim_ac_libtiff_cppflags
#   sim_ac_libtiff_ldflags
#   sim_ac_libtiff_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

AC_DEFUN([SIM_AC_HAVE_LIBTIFF_IFELSE],
[: ${sim_ac_have_libtiff=false}
AC_MSG_CHECKING([for libtiff])
AC_ARG_WITH(
  [tiff],
  [AC_HELP_STRING([--with-tiff=PATH], [enable/disable libtiff support])],
  [case $withval in
  yes | "") sim_ac_want_libtiff=true ;;
  no)       sim_ac_want_libtiff=false ;;
  *)        sim_ac_want_libtiff=true
            sim_ac_libtiff_path=$withval ;;
  esac],
  [sim_ac_want_libtiff=true])
case $sim_ac_want_libtiff in
true)
  $sim_ac_have_libtiff && break
  sim_ac_libtiff_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libtiff_save_LDFLAGS=$LDFLAGS
  sim_ac_libtiff_save_LIBS=$LIBS
  sim_ac_libtiff_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libtiff_debug=true
  # test -z "$sim_ac_libtiff_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libtiff_path=$prefix
  sim_ac_libtiff_name=tiff
  if test -n "$sim_ac_libtiff_path"; then
    for sim_ac_libtiff_candidate in \
      `( ls $sim_ac_libtiff_path/lib/tiff*.lib;
         ls $sim_ac_libtiff_path/lib/tiff*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libtiff_candidate in
      *d.lib)
        $sim_ac_libtiff_debug &&
          sim_ac_libtiff_name=`basename $sim_ac_libtiff_candidate .lib` ;;
      *.lib)
        sim_ac_libtiff_name=`basename $sim_ac_libtiff_candidate .lib` ;;
      esac
    done
    sim_ac_libtiff_cppflags="-I$sim_ac_libtiff_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libtiff_cppflags"
    sim_ac_libtiff_ldflags="-L$sim_ac_libtiff_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libtiff_ldflags"
    # unset sim_ac_libtiff_candidate
    # unset sim_ac_libtiff_path
  fi
  sim_ac_libtiff_libs="-l$sim_ac_libtiff_name"
  LIBS="$sim_ac_libtiff_libs $LIBS"
  AC_TRY_LINK(
    [#include <tiffio.h>],
    [(void)TIFFOpen(0L, 0L);],
    [sim_ac_have_libtiff=true])
  if test x"$sim_ac_have_libtiff" = xfalse; then
    sim_ac_libtiff_libs="-l$sim_ac_libtiff_name -luser32"
    LIBS="$sim_ac_libtiff_libs $sim_ac_libtiff_save_LIBS"
    AC_TRY_LINK(
      [#include <tiffio.h>],
      [(void)TIFFOpen(0L, 0L);],
      [sim_ac_have_libtiff=true])
  fi
  CPPFLAGS=$sim_ac_libtiff_save_CPPFLAGS
  LDFLAGS=$sim_ac_libtiff_save_LDFLAGS
  LIBS=$sim_ac_libtiff_save_LIBS
  # unset sim_ac_libtiff_debug
  # unset sim_ac_libtiff_name
  # unset sim_ac_libtiff_save_CPPFLAGS
  # unset sim_ac_libtiff_save_LDFLAGS
  # unset sim_ac_libtiff_save_LIBS
  ;;
esac
if $sim_ac_want_libtiff; then
  if $sim_ac_have_libtiff; then
    AC_MSG_RESULT([success ($sim_ac_libtiff_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libtiff
])

# EOF **********************************************************************
