# **************************************************************************
# SIM_AC_HAVE_QUARTER_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_quarter
#   sim_ac_quarter_cppflags
#   sim_ac_quarter_ldflags
#   sim_ac_quarter_libs
#
# Authors:
#   Anette Gjetnes <anetteg@sim.no>, based on sps.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_QUARTER_IFELSE],
[: ${sim_ac_have_quarter=false}
AC_MSG_CHECKING([for Quarter])
AC_ARG_WITH(
  [quarter],
  [AC_HELP_STRING([--with-quarter=PATH], [enable/disable Quarter support])],
  [case $withval in
  yes | "") sim_ac_want_quarter=true ;;
  no)       sim_ac_want_quarter=false ;;
  *)        sim_ac_want_quarter=true
            sim_ac_quarter_path=$withval ;;
  esac],
  [sim_ac_want_quarter=true])
case $sim_ac_want_quarter in
true)
  $sim_ac_have_quarter && break
  sim_ac_quarter_save_CPPFLAGS=$CPPFLAGS
  sim_ac_quarter_save_LDFLAGS=$LDFLAGS
  sim_ac_quarter_save_LIBS=$LIBS
  sim_ac_quarter_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_quarter_debug=true
  # test -z "$sim_ac_quarter_path" -a x"$prefix" != xNONE &&
  #   sim_ac_quarter_path=$prefix
  sim_ac_quarter_name=Quarter
  if test -n "$sim_ac_quarter_path"; then
    for sim_ac_quarter_candidate in \
      `( ls $sim_ac_quarter_path/lib/Quarter.lib;
         ls $sim_ac_quarter_path/lib/Quarter.lib ) 2>/dev/null`
    do
      case $sim_ac_quarter_candidate in
      *d.lib)
        $sim_ac_quarter_debug &&
          sim_ac_quarter_name=`basename $sim_ac_quarter_candidate .lib` ;;
      *.lib)
        sim_ac_quarter_name=`basename $sim_ac_quarter_candidate .lib` ;;
      esac
    done
    sim_ac_quarter_cppflags="-I$sim_ac_quarter_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_quarter_cppflags"
    sim_ac_quarter_ldflags="-L$sim_ac_quarter_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_quarter_ldflags"
    # unset sim_ac_quarter_candidate
    # unset sim_ac_quarter_path
  fi
  sim_ac_quarter_libs="-l$sim_ac_quarter_name"
  LIBS="$sim_ac_quarter_libs $LIBS"
  #  echo $LIBS
  AC_TRY_LINK(
    [#include <Quarter/Quarter.h>],
    [SIM::Coin3D::Quarter::Quarter::init();],
    [sim_ac_have_quarter=true])
  CPPFLAGS=$sim_ac_quarter_save_CPPFLAGS
  LDFLAGS=$sim_ac_quarter_save_LDFLAGS
  LIBS=$sim_ac_quarter_save_LIBS
  # unset sim_ac_quarter_debug
  # unset sim_ac_quarter_name
  # unset sim_ac_quarter_save_CPPFLAGS
  # unset sim_ac_quarter_save_LDFLAGS
  # unset sim_ac_quarter_save_LIBS
  ;;
esac
if $sim_ac_want_quarter; then
  if $sim_ac_have_quarter; then
    AC_MSG_RESULT([success ($sim_ac_quarter_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_quarter
])

# EOF **********************************************************************
