# **************************************************************************
# SIM_AC_HAVE_BUX_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_bux
#   sim_ac_bux_cppflags
#   sim_ac_bux_ldflags
#   sim_ac_bux_libs
#
# Authors:
#   Peder Blekken <pederb@coin3d.org>, based on check_zlib.m4

# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_BUX_IFELSE],
[: ${sim_ac_have_bux=false}
AC_MSG_CHECKING([for bux])
AC_ARG_WITH(
  [bux],
  [AC_HELP_STRING([--with-bux=PATH], [enable/disable bux support])],
  [case $withval in
  yes | "") sim_ac_want_bux=true ;;
  no)       sim_ac_want_bux=false ;;
  *)        sim_ac_want_bux=true
            sim_ac_bux_path=$withval ;;
  esac],
  [sim_ac_want_bux=true])
case $sim_ac_want_bux in
true)
  $sim_ac_have_bux && break
  sim_ac_bux_save_CPPFLAGS=$CPPFLAGS
  sim_ac_bux_save_LDFLAGS=$LDFLAGS
  sim_ac_bux_save_LIBS=$LIBS
  sim_ac_bux_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_bux_debug=true
  # test -z "$sim_ac_bux_path" -a x"$prefix" != xNONE &&
  #   sim_ac_bux_path=$prefix
  sim_ac_bux_name=bux
  if test -n "$sim_ac_bux_path"; then
    for sim_ac_bux_candidate in \
      `( ls $sim_ac_bux_path/lib/bux*.lib;
         ls $sim_ac_bux_path/lib/bux*d.lib ) 2>/dev/null`
    do
      case $sim_ac_bux_candidate in
      *d.lib)
        $sim_ac_bux_debug &&
          sim_ac_bux_name=`basename $sim_ac_bux_candidate .lib` ;;
      *.lib)
        sim_ac_bux_name=`basename $sim_ac_bux_candidate .lib` ;;
      esac
    done
    sim_ac_bux_cppflags="-I$sim_ac_bux_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_bux_cppflags"
    sim_ac_bux_ldflags="-L$sim_ac_bux_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_bux_ldflags"
    # unset sim_ac_bux_candidate
    # unset sim_ac_bux_path
  fi
  sim_ac_bux_libs="-l$sim_ac_bux_name"
  LIBS="$sim_ac_bux_libs $LIBS"
  AC_TRY_LINK(
    [#include <bux/document.h>],
    [(void) bux_doc_new();],
    [sim_ac_have_bux=true])
  CPPFLAGS=$sim_ac_bux_save_CPPFLAGS
  LDFLAGS=$sim_ac_bux_save_LDFLAGS
  LIBS=$sim_ac_bux_save_LIBS
  # unset sim_ac_bux_debug
  # unset sim_ac_bux_name
  # unset sim_ac_bux_save_CPPFLAGS
  # unset sim_ac_bux_save_LDFLAGS
  # unset sim_ac_bux_save_LIBS
  ;;
esac
if $sim_ac_want_bux; then
  if $sim_ac_have_bux; then
    AC_MSG_RESULT([success ($sim_ac_bux_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_bux
])

# EOF **********************************************************************
