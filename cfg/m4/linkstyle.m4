############################################################################
# Usage:
#   SIM_AC_CHECK_LINKSTYLE
#
# Description:
#
#   Detect how to link against external libraries; UNIX-style
#   ("-llibname") or MSWin-style ("libname.lib"). As a side-effect of
#   running this macro, the shell variable sim_ac_linking_style will be
#   set to either "mswin" or "unix".
#
# Author:
#   Marius B. Monsen <mariusbu@sim.no>

AC_DEFUN([SIM_AC_CHECK_LINKSTYLE], [

sim_ac_save_ldflags=$LDFLAGS
LDFLAGS="$LDFLAGS version.lib"

AC_CACHE_CHECK(
  [if linking should be done "MSWin-style"],
  sim_cv_mswin_linking,
  AC_TRY_COMPILE([#include <windows.h>
#include <version.h>],
                 [(void)GetFileVersionInfoSize(0L, 0L);],
                 [sim_cv_mswin_linking=yes],
                 [sim_cv_mswin_linking=no])
)

LDFLAGS=$sim_ac_save_ldflags

if test x"$sim_cv_mswin_linking" = x"yes"; then
  sim_ac_linking_style=mswin
else
  sim_ac_linking_style=unix
fi
])
