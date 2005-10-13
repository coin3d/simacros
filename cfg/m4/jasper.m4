# **************************************************************************
# SIM_AC_HAVE_JASPER_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_jasper
#   sim_ac_jasper_cppflags
#   sim_ac_jasper_ldflags
#   sim_ac_jasper_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_JASPER_IFELSE],
[: ${sim_ac_have_jasper=false}
AC_MSG_CHECKING([for jasper])
AC_ARG_WITH(
  [jasper],
  [AC_HELP_STRING([--with-jasper=PATH], [enable/disable jasper (JPEG 2000) support])],
  [case $withval in
  yes | "") sim_ac_want_jasper=true ;;
  no)       sim_ac_want_jasper=false ;;
  *)        sim_ac_want_jasper=true
            sim_ac_jasper_path=$withval ;;
  esac],
  [sim_ac_want_jasper=true])
case $sim_ac_want_jasper in
true)
  $sim_ac_have_jasper && break
  sim_ac_jasper_save_CPPFLAGS=$CPPFLAGS
  sim_ac_jasper_save_LDFLAGS=$LDFLAGS
  sim_ac_jasper_save_LIBS=$LIBS
  sim_ac_jasper_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_jasper_debug=true
  # test -z "$sim_ac_jasper_path" -a x"$prefix" != xNONE &&
  #   sim_ac_jasper_path=$prefix
  sim_ac_jasper_name=jasper
  if test -n "$sim_ac_jasper_path"; then
    for sim_ac_jasper_candidate in \
      `( ls $sim_ac_jasper_path/lib/jasper*.lib;
         ls $sim_ac_jasper_path/lib/jasper*d.lib ) 2>/dev/null`
    do
      case $sim_ac_jasper_candidate in
      *d.lib)
        $sim_ac_jasper_debug &&
          sim_ac_jasper_name=`basename $sim_ac_jasper_candidate .lib` ;;
      *.lib)
        sim_ac_jasper_name=`basename $sim_ac_jasper_candidate .lib` ;;
      esac
    done
    sim_ac_jasper_cppflags="-I$sim_ac_jasper_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_jasper_cppflags"
    sim_ac_jasper_ldflags="-L$sim_ac_jasper_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_jasper_ldflags"
    # unset sim_ac_jasper_candidate
    # unset sim_ac_jasper_path
  fi
  sim_ac_jasper_libs="-l$sim_ac_jasper_name"
  LIBS="$sim_ac_jasper_libs $LIBS"
  AC_TRY_LINK(
  [#include <jasper/jasper.h>],
  [(void)jas_init();],
  [sim_ac_have_jasper=true])
  CPPFLAGS=$sim_ac_jasper_save_CPPFLAGS
  LDFLAGS=$sim_ac_jasper_save_LDFLAGS
  LIBS=$sim_ac_jasper_save_LIBS
  # unset sim_ac_jasper_debug
  # unset sim_ac_jasper_name
  # unset sim_ac_jasper_save_CPPFLAGS
  # unset sim_ac_jasper_save_LDFLAGS
  # unset sim_ac_jasper_save_LIBS
  ;;
esac
if $sim_ac_want_jasper; then
  if $sim_ac_have_jasper; then
    AC_MSG_RESULT([success ($sim_ac_jasper_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_jasper
])

# EOF **********************************************************************
