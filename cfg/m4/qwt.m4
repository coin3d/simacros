# **************************************************************************
# SIM_AC_HAVE_QWT_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_qwt
#   sim_ac_qwt_cppflags
#   sim_ac_qwt_ldflags
#   sim_ac_qwt_libs
#
# Authors:
#   Anette Gjetnes <anetteg@sim.no>, based on sps.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_QWT_IFELSE],
[: ${sim_ac_have_qwt=false}
AC_MSG_CHECKING([for Qwt])
AC_ARG_WITH(
  [qwt],
  [AC_HELP_STRING([--with-qwt=PATH], [enable/disable Qwt support])],
  [case $withval in
  yes | "") sim_ac_want_qwt=true ;;
  no)       sim_ac_want_qwt=false ;;
  *)        sim_ac_want_qwt=true
            sim_ac_qwt_path=$withval ;;
  esac],
  [sim_ac_want_qwt=true])
case $sim_ac_want_qwt in
true)
  $sim_ac_have_qwt && break
  sim_ac_qwt_save_CPPFLAGS=$CPPFLAGS
  sim_ac_qwt_save_LDFLAGS=$LDFLAGS
  sim_ac_qwt_save_LIBS=$LIBS
  sim_ac_qwt_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_qwt_debug=true
  # test -z "$sim_ac_qwt_path" -a x"$prefix" != xNONE &&
  #   sim_ac_qwt_path=$prefix
  sim_ac_qwt_name=qwt
  if test -n "$sim_ac_qwt_path"; then
    for sim_ac_qwt_candidate in \
      `( ls $sim_ac_qwt_path/lib/qwt*.lib;
         ls $sim_ac_qwt_path/lib/qwt*d.lib ) 2>/dev/null`
    do
      case $sim_ac_qwt_candidate in
      *d.lib)
        $sim_ac_qwt_debug &&
          sim_ac_qwt_name=`basename $sim_ac_qwt_candidate .lib` ;;
      *.lib)
        sim_ac_qwt_name=`basename $sim_ac_qwt_candidate .lib` ;;
      esac
    done
    sim_ac_qwt_cppflags="-I$sim_ac_qwt_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_qwt_cppflags"
    sim_ac_qwt_ldflags="-L$sim_ac_qwt_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_qwt_ldflags"
    # unset sim_ac_qwt_candidate
    # unset sim_ac_qwt_path
  fi
  sim_ac_qwt_libs="-l$sim_ac_qwt_name"
  LIBS="$LIBS $sim_ac_qwt_libs"
  AC_TRY_LINK(
    [#include <qwt_plot.h>],
    [QwtPlot * plot = new QwtPlot(QString("Two Curves"));],
    [sim_ac_have_qwt=true])
  CPPFLAGS=$sim_ac_qwt_save_CPPFLAGS
  LDFLAGS=$sim_ac_qwt_save_LDFLAGS
  LIBS=$sim_ac_qwt_save_LIBS
  # unset sim_ac_qwt_debug
  # unset sim_ac_qwt_name
  # unset sim_ac_qwt_save_CPPFLAGS
  # unset sim_ac_qwt_save_LDFLAGS
  # unset sim_ac_qwt_save_LIBS
  ;;
esac
if $sim_ac_want_qwt; then
  if $sim_ac_have_qwt; then
    AC_MSG_RESULT([success ($sim_ac_qwt_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_qwt
])

# EOF **********************************************************************
