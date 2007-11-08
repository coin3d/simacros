# **************************************************************************
# SIM_AC_HAVE_CASH_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_cash
#   sim_ac_cash_cppflags
#   sim_ac_cash_ldflags
#   sim_ac_cash_libs
#
# Authors:
#   Anette Gjetnes <anetteg@sim.no>, based on sps.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_CASH_IFELSE],
[: ${sim_ac_have_cash=false}
AC_MSG_CHECKING([for CASH])
AC_ARG_WITH(
  [cash],
  [AC_HELP_STRING([--with-cash=PATH], [enable/disable Cash support])],
  [case $withval in
  yes | "") sim_ac_want_cash=true ;;
  no)       sim_ac_want_cash=false ;;
  *)        sim_ac_want_cash=true
            sim_ac_cash_path=$withval ;;
  esac],
  [sim_ac_want_cash=true])
case $sim_ac_want_cash in
true)
  $sim_ac_have_cash && break
  sim_ac_cash_save_CPPFLAGS=$CPPFLAGS
  sim_ac_cash_save_LDFLAGS=$LDFLAGS
  sim_ac_cash_save_LIBS=$LIBS
  sim_ac_cash_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_cash_debug=true
  # test -z "$sim_ac_cash_path" -a x"$prefix" != xNONE &&
  #   sim_ac_cash_path=$prefix
  sim_ac_cash_name=Cash
  if test -n "$sim_ac_cash_path"; then
    for sim_ac_cash_candidate in \
      `( ls $sim_ac_cash_path/lib/Cash*.lib;
         ls $sim_ac_cash_path/lib/Cash*d.lib ) 2>/dev/null`
    do
      case $sim_ac_cash_candidate in
      *d.lib)
        $sim_ac_cash_debug &&
          sim_ac_cash_name=`basename $sim_ac_cash_candidate .lib` ;;
      *.lib)
        sim_ac_cash_name=`basename $sim_ac_cash_candidate .lib` ;;
      esac
    done
    sim_ac_cash_cppflags="-I$sim_ac_cash_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_cash_cppflags"
    sim_ac_cash_ldflags="-L$sim_ac_cash_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_cash_ldflags"
    # unset sim_ac_cash_candidate
    # unset sim_ac_cash_path
  fi
  sim_ac_cash_libs="-l$sim_ac_cash_name"
  LIBS="$sim_ac_cash_libs $LIBS"
  AC_TRY_LINK(
    [#include <Cash/Cache.h>],
    [Cash::Cache * cash = new Cash::Cache(1000);],
    [sim_ac_have_cash=true])
  CPPFLAGS=$sim_ac_cash_save_CPPFLAGS
  LDFLAGS=$sim_ac_cash_save_LDFLAGS
  LIBS=$sim_ac_cash_save_LIBS
  # unset sim_ac_cash_debug
  # unset sim_ac_cash_name
  # unset sim_ac_cash_save_CPPFLAGS
  # unset sim_ac_cash_save_LDFLAGS
  # unset sim_ac_cash_save_LIBS
  ;;
esac
if $sim_ac_want_cash; then
  if $sim_ac_have_cash; then
    AC_MSG_RESULT([success ($sim_ac_cash_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_cash
])

# EOF **********************************************************************
