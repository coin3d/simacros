############################################################################
# Usage:
# SIM_CHECK_BE([ ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND ]])
#
# This macro checks if we are building on a BeOS system.
#
# Variables:
#   $sim_cv_headers_be           (cached)  yes | no
#   $sim_cv_lib_be               (cached)  yes | no
#   $sim_ac_be_avail                       yes | no
#
#   $sim_ac_be_cppflags
#   $sim_ac_be_ldflags
#   $sim_ac_be_libs
#
# Defines:
#   <none>
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#

AC_DEFUN([SIM_CHECK_BE],[
AC_PREREQ([2.14.1])
AC_CACHE_CHECK([for Be header files], sim_cv_headers_be, [
  AC_LANG_SAVE
  AC_LANG_CPLUSPLUS
  AC_TRY_CPP([#include <app/Application.h>],
             [sim_cv_headers_be=yes],
             [sim_cv_headers_be=no])
  AC_LANG_RESTORE
])

if test "x$sim_cv_headers_be" != "xyes"; then
  sim_ac_be_avail=no
  $2
else
  AC_CACHE_CHECK([for Be API library], sim_cv_lib_be, [
    AC_LANG_SAVE
    AC_LANG_CPLUSPLUS
    SAVELIBS="$LIBS"
    LIBS=-lbe
    AC_TRY_LINK([#include <app/Application.h>],
                [new BApplication("application/ac-test")],
                [sim_cv_lib_be=yes],
                [sim_cv_lib_be=no])
    LIBS="$SAVELIBS"
    AC_LANG_RESTORE
  ])

  if test "x$sim_cv_lib_be" != "xyes"; then
    sim_ac_be_avail=no
    $2
  else
    sim_ac_be_avail=yes
    sim_ac_be_cppflags=
    sim_ac_be_ldflags=
    sim_ac_be_libs=
    $1
  fi
fi
])

