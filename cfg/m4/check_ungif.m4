# **************************************************************************
# SIM_AC_HAVE_LIBUNGIF_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libungif
#   sim_ac_libungif_cppflags
#   sim_ac_libungif_ldflags
#   sim_ac_libungif_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>
#   Morten Eriksen <mortene@coin3d.org>
#
# Todo:
# - use AS_UNSET to unset internal variables to avoid polluting the environment
#

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBUNGIF_IFELSE],
[AC_REQUIRE([AC_PATH_X])
: ${sim_ac_have_libungif=false}
AC_MSG_CHECKING([for libungif])
AC_ARG_WITH(
  [ungif],
  [AC_HELP_STRING([--with-ungif=PATH], [enable/disable libungif support])],
  [case $withval in
  yes | "") sim_ac_want_libungif=true ;;
  no)       sim_ac_want_libungif=false ;;
  *)        sim_ac_want_libungif=true
            sim_ac_libungif_path=$withval ;;
  esac],
  [sim_ac_want_libungif=true])
case $sim_ac_want_libungif in
true)
  $sim_ac_have_libungif && break
  sim_ac_libungif_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libungif_save_LDFLAGS=$LDFLAGS
  sim_ac_libungif_save_LIBS=$LIBS
  sim_ac_libungif_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libungif_debug=true
  # test -z "$sim_ac_libungif_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libungif_path=$prefix
  sim_ac_libungif_name=ungif
  if test -n "$sim_ac_libungif_path"; then
    for sim_ac_libungif_candidate in \
      `( ls $sim_ac_libungif_path/lib/ungif*.lib;
         ls $sim_ac_libungif_path/lib/ungif*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libungif_candidate in
      *d.lib)
        $sim_ac_libungif_debug &&
          sim_ac_libungif_name=`basename $sim_ac_libungif_candidate .lib` ;;
      *.lib)
        sim_ac_libungif_name=`basename $sim_ac_libungif_candidate .lib` ;;
      esac
    done
    sim_ac_libungif_cppflags="-I$sim_ac_libungif_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libungif_cppflags"
    sim_ac_libungif_ldflags="-L$sim_ac_libungif_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libungif_ldflags"
    # unset sim_ac_libungif_candidate
    # unset sim_ac_libungif_path
  fi
  sim_ac_libungif_libs="-l$sim_ac_libungif_name"
  LIBS="$sim_ac_libungif_libs $LIBS"
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
    [sim_ac_have_libungif=true])
  # libungif has become dependent on Xlib :(
  if test x"$sim_ac_have_libungif" = xfalse; then
    if test x"$x_includes" != x""; then
      sim_ac_libungif_cppflags="$sim_ac_libungif_cppflags -I$x_includes"
      CPPFLAGS="$sim_ac_libungif_cppflags $sim_ac_libungif_save_CPPFLAGS"
    fi
    if test x"$x_libraries" != x""; then
      sim_ac_libungif_ldflags="$sim_ac_libungif_ldflags -L$x_libraries"
      LDFLAGS="$sim_ac_libungif_ldflags $sim_ac_libungif_save_LDFLAGS"
    fi
    sim_ac_libungif_libs="-l$sim_ac_libungif_name -lX11"
    LIBS="$sim_ac_libungif_libs $sim_ac_libungif_save_LIBS"
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
      [sim_ac_have_libungif=true])
  fi
  CPPFLAGS=$sim_ac_libungif_save_CPPFLAGS
  LDFLAGS=$sim_ac_libungif_save_LDFLAGS
  LIBS=$sim_ac_libungif_save_LIBS
  # unset sim_ac_libungif_debug
  # unset sim_ac_libungif_name
  # unset sim_ac_libungif_save_CPPFLAGS
  # unset sim_ac_libungif_save_LDFLAGS
  # unset sim_ac_libungif_save_LIBS
  ;;
esac

if $sim_ac_want_libungif; then
  if $sim_ac_have_libungif; then
    AC_MSG_RESULT([success ($sim_ac_libungif_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libungif
])

# EOF **********************************************************************
