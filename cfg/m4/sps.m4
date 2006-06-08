# **************************************************************************
# SIM_AC_HAVE_SPS_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_sps
#   sim_ac_sps_cppflags
#   sim_ac_sps_ldflags
#   sim_ac_sps_libs
#
# Authors:
#   Peder Blekken <pederb@coin3d.org>, based on check_zlib.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_SPS_IFELSE],
[: ${sim_ac_have_sps=false}
AC_MSG_CHECKING([for SPS])
AC_ARG_WITH(
  [sps],
  [AC_HELP_STRING([--with-sps=PATH], [enable/disable SPS support])],
  [case $withval in
  yes | "") sim_ac_want_sps=true ;;
  no)       sim_ac_want_sps=false ;;
  *)        sim_ac_want_sps=true
            sim_ac_sps_path=$withval ;;
  esac],
  [sim_ac_want_sps=true])
case $sim_ac_want_sps in
true)
  $sim_ac_have_sps && break
  sim_ac_sps_save_CPPFLAGS=$CPPFLAGS
  sim_ac_sps_save_LDFLAGS=$LDFLAGS
  sim_ac_sps_save_LIBS=$LIBS
  sim_ac_sps_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_sps_debug=true
  # test -z "$sim_ac_sps_path" -a x"$prefix" != xNONE &&
  #   sim_ac_sps_path=$prefix
  sim_ac_sps_name=sps
  if test -n "$sim_ac_sps_path"; then
    for sim_ac_sps_candidate in \
      `( ls $sim_ac_sps_path/lib/SPS*.lib;
         ls $sim_ac_sps_path/lib/SPS*d.lib ) 2>/dev/null`
    do
      case $sim_ac_sps_candidate in
      *d.lib)
        $sim_ac_sps_debug &&
          sim_ac_sps_name=`basename $sim_ac_sps_candidate .lib` ;;
      *.lib)
        sim_ac_sps_name=`basename $sim_ac_sps_candidate .lib` ;;
      esac
    done
    sim_ac_sps_cppflags="-I$sim_ac_sps_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_sps_cppflags"
    sim_ac_sps_ldflags="-L$sim_ac_sps_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_sps_ldflags"
    # unset sim_ac_sps_candidate
    # unset sim_ac_sps_path
  fi
  sim_ac_sps_libs="-l$sim_ac_sps_name"
  LIBS="$sim_ac_sps_libs $LIBS"
  AC_TRY_LINK(
    [#include <SPS/database.h>],
    [sps_database database((sps_backend*)0);],
    [sim_ac_have_sps=true])
  CPPFLAGS=$sim_ac_sps_save_CPPFLAGS
  LDFLAGS=$sim_ac_sps_save_LDFLAGS
  LIBS=$sim_ac_sps_save_LIBS
  # unset sim_ac_sps_debug
  # unset sim_ac_sps_name
  # unset sim_ac_sps_save_CPPFLAGS
  # unset sim_ac_sps_save_LDFLAGS
  # unset sim_ac_sps_save_LIBS
  ;;
esac
if $sim_ac_want_sps; then
  if $sim_ac_have_sps; then
    AC_MSG_RESULT([success ($sim_ac_sps_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_sps
])

# EOF **********************************************************************
