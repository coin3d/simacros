# **************************************************************************
# SIM_AC_HAVE_LIBBZIP2_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libbzip2
#   sim_ac_libbzip2_cppflags
#   sim_ac_libbzip2_cflags
#   sim_ac_libbzip2_cxxflags
#   sim_ac_libbzip2_ldflags
#   sim_ac_libbzip2_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBBZIP2_IFELSE],
[: ${sim_ac_have_libbzip2=false}
AC_MSG_CHECKING([for bzip2 (library)])
AC_ARG_WITH(
  [zlib],
  [AC_HELP_STRING([--with-bzip2=PATH], [enable/disable bzip2 support])],
  [case $withval in
  yes | "") sim_ac_want_libbzip2=true ;;
  no)       sim_ac_want_libbzip2=false ;;
  *)        sim_ac_want_libbzip2=true
            sim_ac_libbzip2_path=$withval ;;
  esac],
  [sim_ac_want_libbzip2=true])
case $sim_ac_want_libbzip2 in
true)
  $sim_ac_have_libbzip2 && break
  sim_ac_libbzip2_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libbzip2_save_LDFLAGS=$LDFLAGS
  sim_ac_libbzip2_save_LIBS=$LIBS
  sim_ac_libbzip2_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libbzip2_debug=true
  # test -z "$sim_ac_libbzip2_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libbzip2_path=$prefix
  sim_ac_libbzip2_name=bz2
  if test -n "$sim_ac_libbzip2_path"; then
    for sim_ac_libbzip2_candidate in \
      `( ls $sim_ac_libbzip2_path/lib/bzip2*.lib;
         ls $sim_ac_libbzip2_path/lib/bzip2*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libbzip2_candidate in
      *d.lib)
        $sim_ac_libbzip2_debug &&
          sim_ac_libbzip2_name=`basename $sim_ac_libbzip2_candidate .lib` ;;
      *.lib)
        sim_ac_libbzip2_name=`basename $sim_ac_libbzip2_candidate .lib` ;;
      esac
    done
    sim_ac_libbzip2_cppflags="-I$sim_ac_libbzip2_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libbzip2_cppflags"
    sim_ac_libbzip2_ldflags="-L$sim_ac_libbzip2_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libbzip2_ldflags"
    # unset sim_ac_libbzip2_candidate
    # unset sim_ac_libbzip2_path
  fi
  sim_ac_libbzip2_libs="-l$sim_ac_libbzip2_name"
  LIBS="$sim_ac_libbzip2_libs $LIBS"
  AC_TRY_LINK(
    [#include <bzlib.h>],
    [(void)BZ2_bzlibVersion();],
    [sim_ac_have_libbzip2=true])
  CPPFLAGS=$sim_ac_libbzip2_save_CPPFLAGS
  LDFLAGS=$sim_ac_libbzip2_save_LDFLAGS
  LIBS=$sim_ac_libbzip2_save_LIBS
  # unset sim_ac_libbzip2_debug
  # unset sim_ac_libbzip2_name
  # unset sim_ac_libbzip2_save_CPPFLAGS
  # unset sim_ac_libbzip2_save_LDFLAGS
  # unset sim_ac_libbzip2_save_LIBS
  ;;
esac
if $sim_ac_want_libbzip2; then
  if $sim_ac_have_libbzip2; then
    AC_MSG_RESULT([success ($sim_ac_libbzip2_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libbzip2
])

# EOF **********************************************************************
