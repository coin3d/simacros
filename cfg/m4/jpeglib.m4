# **************************************************************************
# SIM_AC_HAVE_LIBJPEG_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libjpeg
#   sim_ac_libjpeg_cppflags
#   sim_ac_libjpeg_ldflags
#   sim_ac_libjpeg_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBJPEG_IFELSE],
[: ${sim_ac_have_libjpeg=false}
AC_MSG_CHECKING([for libjpeg])
AC_ARG_WITH(
  [jpeg],
  [AC_HELP_STRING([--with-jpeg=PATH], [enable/disable libjpeg support])],
  [case $withval in
  yes | "") sim_ac_want_libjpeg=true ;;
  no)       sim_ac_want_libjpeg=false ;;
  *)        sim_ac_want_libjpeg=true
            sim_ac_libjpeg_path=$withval ;;
  esac],
  [sim_ac_want_libjpeg=true])
case $sim_ac_want_libjpeg in
true)
  $sim_ac_have_libjpeg && break
  sim_ac_libjpeg_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libjpeg_save_LDFLAGS=$LDFLAGS
  sim_ac_libjpeg_save_LIBS=$LIBS
  sim_ac_libjpeg_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libjpeg_debug=true
  # test -z "$sim_ac_libjpeg_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libjpeg_path=$prefix
  sim_ac_libjpeg_name=jpeg
  if test -n "$sim_ac_libjpeg_path"; then
    for sim_ac_libjpeg_candidate in \
      `( ls $sim_ac_libjpeg_path/lib/jpeg*.lib;
         ls $sim_ac_libjpeg_path/lib/jpeg*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libjpeg_candidate in
      *d.lib)
        $sim_ac_libjpeg_debug &&
          sim_ac_libjpeg_name=`basename $sim_ac_libjpeg_candidate .lib` ;;
      *.lib)
        sim_ac_libjpeg_name=`basename $sim_ac_libjpeg_candidate .lib` ;;
      esac
    done
    sim_ac_libjpeg_cppflags="-I$sim_ac_libjpeg_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libjpeg_cppflags"
    sim_ac_libjpeg_ldflags="-L$sim_ac_libjpeg_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libjpeg_ldflags"
    # unset sim_ac_libjpeg_candidate
    # unset sim_ac_libjpeg_path
  fi
  sim_ac_libjpeg_libs="-l$sim_ac_libjpeg_name"
  LIBS="$sim_ac_libjpeg_libs $LIBS"
  AC_TRY_LINK(
    [#include <stdio.h>
#ifdef __cplusplus
extern "C" { // libjpeg header is missing the C++ wrapper
#endif
#include <jpeglib.h>
#ifdef __cplusplus
}
#endif],
  [(void)jpeg_read_header(0L, 0);],
  [sim_ac_have_libjpeg=true])
  CPPFLAGS=$sim_ac_libjpeg_save_CPPFLAGS
  LDFLAGS=$sim_ac_libjpeg_save_LDFLAGS
  LIBS=$sim_ac_libjpeg_save_LIBS
  # unset sim_ac_libjpeg_debug
  # unset sim_ac_libjpeg_name
  # unset sim_ac_libjpeg_save_CPPFLAGS
  # unset sim_ac_libjpeg_save_LDFLAGS
  # unset sim_ac_libjpeg_save_LIBS
  ;;
esac
if $sim_ac_want_libjpeg; then
  if $sim_ac_have_libjpeg; then
    AC_MSG_RESULT([success ($sim_ac_libjpeg_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libjpeg
])

# EOF **********************************************************************
