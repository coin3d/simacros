# **************************************************************************
# SIM_AC_HAVE_LIBSCENERY_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_libscenery
#   sim_ac_libscenery_cppflags
#   sim_ac_libscenery_ldflags
#   sim_ac_libscenery_libs
#
# Authors:
#   Lars J. Aas <larsa@coin3d.org>

# **************************************************************************

AC_DEFUN([SIM_AC_HAVE_LIBSCENERY_IFELSE],
[AC_REQUIRE([AC_PATH_X])
: ${sim_ac_have_libscenery=false}
AC_MSG_CHECKING([for libscenery])
AC_ARG_WITH(
  [scenery],
  [AC_HELP_STRING([--with-scenery=PATH], [enable/disable libscenery support])],
  [case $withval in
  yes | "") sim_ac_want_libscenery=true ;;
  no)       sim_ac_want_libscenery=false ;;
  *)        sim_ac_want_libscenery=true
            sim_ac_libscenery_path=$withval ;;
  esac],
  [sim_ac_want_libscenery=true])

case $sim_ac_want_libscenery in
true)
  $sim_ac_have_libscenery && break
  sim_ac_libscenery_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libscenery_save_LDFLAGS=$LDFLAGS
  sim_ac_libscenery_save_LIBS=$LIBS
  sim_ac_libscenery_debug=false
  test -z "$sim_ac_libscenery_path" -a x"$prefix" != xNONE &&
    sim_ac_libscenery_path=$prefix
  sim_ac_libscenery_name=scenery
  if test -n "$sim_ac_libscenery_path"; then
    sim_ac_libscenery_cppflags="-I$sim_ac_libscenery_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libscenery_cppflags"
    sim_ac_libscenery_ldflags="-L$sim_ac_libscenery_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libscenery_ldflags"
  fi

  AC_TRY_COMPILE([
#include <sim/scenery/scenery.h>
], [
    ss_initialize();
], [
    true
], [
    # failed - try with SS_DLL defined
    CPPFLAGS="$CPPFLAGS -DSS_DLL"
    AC_TRY_COMPILE([
#include <sim/scenery/scenery.h>
], [
      ss_initialize();
], [
      sim_ac_libscenery_cppflags="$sim_ac_libscenery_cppflags -DSS_DLL"
])])

  sim_ac_libscenery_libs="-lscenery"
  LIBS="$sim_ac_libscenery_libs $LIBS"
  AC_TRY_LINK([
#include <sim/scenery/scenery.h>
], [
    ss_initialize();
], [
    sim_ac_have_libscenery=true])
  if test x"$sim_ac_have_libscenery" = x"false"; then
    # maybe with Guile
    sim_ac_libscenery_libs="$sim_ac_libscenery_libs -lguile"
    LIBS="$sim_ac_libscenery_libs $sim_ac_libscenery_save_LIBS"
    AC_TRY_LINK([
#include <sim/scenery/scenery.h>
], [
      ss_initialize();
], [
      sim_ac_have_libscenery=true])
  fi
  if test x"$sim_ac_have_libscenery" = x"false"; then
    # maybe with our special Guile156
    sim_ac_libscenery_libs="${sim_ac_libscenery_libs}156"
    LIBS="$sim_ac_libscenery_libs $sim_ac_libscenery_save_LIBS"
    AC_TRY_LINK([
#include <sim/scenery/scenery.h>
], [
      ss_initialize();
], [
      sim_ac_have_libscenery=true])
  fi

  CPPFLAGS=$sim_ac_libscenery_save_CPPFLAGS
  LDFLAGS=$sim_ac_libscenery_save_LDFLAGS
  LIBS=$sim_ac_libscenery_save_LIBS
  ;;
esac

if $sim_ac_want_libscenery; then
  if $sim_ac_have_libscenery; then
    AC_MSG_RESULT([success ($sim_ac_libscenery_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
])

# EOF **********************************************************************
