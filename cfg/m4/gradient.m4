# **************************************************************************
# SIM_AC_HAVE_GRADIENT_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_gradient
#   sim_ac_gradient_cppflags
#   sim_ac_gradient_ldflags
#   sim_ac_gradient_libs
#
# Authors:
#   Frode Øijord <frodo@sim.no>, based on check_zlib.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_GRADIENT_IFELSE],
[: ${sim_ac_have_gradient=false}
AC_MSG_CHECKING([for gradient])
AC_ARG_WITH(
  [gradient],
  [AC_HELP_STRING([--with-gradient=PATH], [enable/disable gradient support])],
  [case $withval in
  yes | "") sim_ac_want_gradient=true ;;
  no)       sim_ac_want_gradient=false ;;
  *)        sim_ac_want_gradient=true
            sim_ac_gradient_path=$withval ;;
  esac],
  [sim_ac_want_gradient=true])
case $sim_ac_want_gradient in
true)
  $sim_ac_have_gradient && break
  sim_ac_gradient_save_CPPFLAGS=$CPPFLAGS
  sim_ac_gradient_save_LDFLAGS=$LDFLAGS
  sim_ac_gradient_save_LIBS=$LIBS
  sim_ac_gradient_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_gradient_debug=true
  # test -z "$sim_ac_gradient_path" -a x"$prefix" != xNONE &&
  #   sim_ac_gradient_path=$prefix
  sim_ac_gradient_name=Gradient
  if test -n "$sim_ac_gradient_path"; then
    for sim_ac_gradient_candidate in \
      `( ls $sim_ac_gradient_path/lib/Gradient*.lib;
         ls $sim_ac_gradient_path/lib/Gradient*d.lib ) 2>/dev/null`
    do
      case $sim_ac_gradient_candidate in
      *d.lib)
        $sim_ac_gradient_debug &&
          sim_ac_gradient_name=`basename $sim_ac_gradient_candidate .lib` ;;
      *.lib)
        sim_ac_gradient_name=`basename $sim_ac_gradient_candidate .lib` ;;
      esac
    done
    sim_ac_gradient_cppflags="-I$sim_ac_gradient_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_gradient_cppflags"
    sim_ac_gradient_ldflags="-L$sim_ac_gradient_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_gradient_ldflags"
    # unset sim_ac_gradient_candidate
    # unset sim_ac_gradient_path
  fi
  sim_ac_gradient_libs="-l$sim_ac_gradient_name"
  LIBS="$sim_ac_gradient_libs $LIBS"
  AC_TRY_LINK(
    [#include <Gradient/conftest.h>],
    [(void) conftest();],
    [sim_ac_have_gradient=true])
  CPPFLAGS=$sim_ac_gradient_save_CPPFLAGS
  LDFLAGS=$sim_ac_gradient_save_LDFLAGS
  LIBS=$sim_ac_gradient_save_LIBS
  # unset sim_ac_gradient_debug
  # unset sim_ac_gradient_name
  # unset sim_ac_gradient_save_CPPFLAGS
  # unset sim_ac_gradient_save_LDFLAGS
  # unset sim_ac_gradient_save_LIBS
  ;;
esac
if $sim_ac_want_gradient; then
  if $sim_ac_have_gradient; then
    AC_MSG_RESULT([success ($sim_ac_gradient_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_gradient
])

# EOF **********************************************************************
