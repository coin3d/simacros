############################################################################
# Usage:
#  SIM_CHECK_SDEAPI([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
#  Try to compile and link against the ArcSDE C-api library. Sets these
#  shell variables:
#
#    $sim_ac_sdeapi_cppflags (extra flags the compiler needs for ArcSDE C-api)
#    $sim_ac_sdeapi_ldflags  (extra flags the linker needs for ArcSDE C-api)
#    $sim_ac_sdeapi_libs     (link libraries the linker needs for ArcSDE C-api)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#  In addition, the variable $sim_ac_sdeapi_avail is set to "yes" if
#  the ArcSDE C-api library development installation is ok.
#
# Author: Frode Øijord, <frodo@sim.no>.
# Cut-and-paste from check_motif.m4, check for Motif library

AC_DEFUN([SIM_CHECK_SDEAPI], [
AC_PREREQ([2.14.1])

AC_ARG_WITH(
  [sdeapi],
  AC_HELP_STRING([--with-sdeapi=DIR],
                 [use the ArcSDE C-api library [default=no]]),
  [],
  [with_sdeapi=no])

sim_ac_sdeapi_avail=no

if test x"$with_sdeapi" != xno; then
  if test x"$with_sdeapi" != xyes; then
    sim_ac_sdeapi_cppflags="-I${with_sdeapi}/include"
    sim_ac_sdeapi_ldflags="-L${with_sdeapi}/lib"
  fi

  sim_ac_sdeapi_libs="-lsde90 -lpe90"

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$sim_ac_sdeapi_cppflags $CPPFLAGS"
  LDFLAGS="$sim_ac_sdeapi_ldflags $LDFLAGS"
  LIBS="$sim_ac_sdeapi_libs $LIBS"

  AC_CACHE_CHECK(
    [for a Sdeapi development environment],
    sim_cv_lib_sdeapi_avail,
    [AC_TRY_LINK([#include <sdetype.h>],
                 [SE_ERROR error;
                  SE_CONNECTION connection;
                  LONG rc = SE_connection_create("", "", "", "", "", &error, &connection);],
                 [sim_cv_lib_sdeapi_avail=yes],
                 [sim_cv_lib_sdeapi_avail=no])])

  if test x"$sim_cv_lib_sdeapi_avail" = xyes; then
    sim_ac_sdeapi_avail=yes
    $1
  else
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
    $2
  fi
fi
])
