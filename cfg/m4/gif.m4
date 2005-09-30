# **************************************************************************
# SIM_AC_HAVE_GIFLIB_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_giflib
#   sim_ac_giflib_cppflags
#   sim_ac_giflib_ldflags
#   sim_ac_giflib_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#   Tamer Fahmy <tamer@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
# - remove ungif.m4
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_GIFLIB_IFELSE],
[AC_REQUIRE([SIM_AC_CHECK_X11])
: ${sim_ac_have_giflib=false}
AC_MSG_CHECKING([for giflib])
AC_ARG_WITH(
  [gif],
  [AC_HELP_STRING([--with-gif=PATH], [enable/disable giflib support])],
  [case $withval in
  yes | "") sim_ac_want_giflib=true ;;
  no)       sim_ac_want_giflib=false ;;
  *)        sim_ac_want_giflib=true
            sim_ac_giflib_path=$withval ;;
  esac],
  [sim_ac_want_giflib=true])
case $sim_ac_want_giflib in
true)
  $sim_ac_have_giflib && break
  sim_ac_giflib_save_CPPFLAGS=$CPPFLAGS
  sim_ac_giflib_save_LDFLAGS=$LDFLAGS
  sim_ac_giflib_save_LIBS=$LIBS
  sim_ac_giflib_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_giflib_debug=true
  # test -z "$sim_ac_giflib_path" -a x"$prefix" != xNONE &&
  #   sim_ac_giflib_path=$prefix
  sim_ac_giflib_name=gif
  if test -n "$sim_ac_giflib_path"; then
    for sim_ac_giflib_candidate in \
      `( ls $sim_ac_giflib_path/lib/gif*.lib;
         ls $sim_ac_giflib_path/lib/gif*d.lib ) 2>/dev/null`
    do
      case $sim_ac_giflib_candidate in
      *d.lib)
        $sim_ac_giflib_debug &&
          sim_ac_giflib_name=`basename $sim_ac_giflib_candidate .lib` ;;
      *.lib)
        sim_ac_giflib_name=`basename $sim_ac_giflib_candidate .lib` ;;
      esac
    done
    sim_ac_giflib_cppflags="-I$sim_ac_giflib_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_giflib_cppflags"
    sim_ac_giflib_ldflags="-L$sim_ac_giflib_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_giflib_ldflags"
    # unset sim_ac_giflib_candidate
    # unset sim_ac_giflib_path
  fi
  sim_ac_giflib_libs="-l$sim_ac_giflib_name"
  LIBS="$sim_ac_giflib_libs $LIBS"
  AC_TRY_LINK(
    [
#ifdef __cplusplus /* gif_lib.h (at least v4.0) has no C++ wrapper */
extern "C" {
#endif /* __cplusplus */
#include <gif_lib.h>
#ifdef __cplusplus
}
#endif /* __cplusplus */
],
    [(void)EGifOpenFileName(0L, 0);],
    [sim_ac_have_giflib=true])
  # giflib has become dependent on Xlib :(
  if test x"$sim_ac_have_giflib" = xfalse; then
    if test x"$x_includes" != x""; then
      sim_ac_giflib_cppflags="$sim_ac_giflib_cppflags -I$x_includes"
      CPPFLAGS="$sim_ac_giflib_cppflags $sim_ac_giflib_save_CPPFLAGS"
    fi
    if test x"$x_libraries" != x""; then
      sim_ac_giflib_ldflags="$sim_ac_giflib_ldflags -L$x_libraries"
      LDFLAGS="$sim_ac_giflib_ldflags $sim_ac_giflib_save_LDFLAGS"
    fi
    sim_ac_giflib_libs="-l$sim_ac_giflib_name -lX11"
    LIBS="$sim_ac_giflib_libs $sim_ac_giflib_save_LIBS"
    AC_TRY_LINK(
      [
#ifdef __cplusplus /* gif_lib.h (at least v4.0) has no C++ wrapper */
extern "C" {
#endif /* __cplusplus */
#include <gif_lib.h>
#ifdef __cplusplus
}
#endif /* __cplusplus */
],
      [(void)EGifOpenFileName(0L, 0);],
      [sim_ac_have_giflib=true])
  fi
  CPPFLAGS=$sim_ac_giflib_save_CPPFLAGS
  LDFLAGS=$sim_ac_giflib_save_LDFLAGS
  LIBS=$sim_ac_giflib_save_LIBS
  # unset sim_ac_giflib_debug
  # unset sim_ac_giflib_name
  # unset sim_ac_giflib_save_CPPFLAGS
  # unset sim_ac_giflib_save_LDFLAGS
  # unset sim_ac_giflib_save_LIBS
  ;;
esac

if $sim_ac_want_giflib; then
  if $sim_ac_have_giflib; then
    AC_MSG_RESULT([success ($sim_ac_giflib_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_giflib
])

# EOF **********************************************************************
