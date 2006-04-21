# **************************************************************************
# SIM_AC_HAVE_GDIPLUS_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_gdiplus
#   sim_ac_gdiplus_libs
#
# Authors:
#   Tamer Fahmy <tamer@sim.no>

AC_DEFUN([SIM_AC_HAVE_GDIPLUS_IFELSE],
[: ${sim_ac_have_gdiplus=false}
AC_MSG_CHECKING([for GDI+])
$sim_ac_have_gdiplus && break
sim_ac_gdiplus_save_LIBS=$LIBS
sim_ac_gdiplus_libs="-lgdiplus"
LIBS="$sim_ac_gdiplus_libs $LIBS"
AC_CHECK_HEADERS([windows.h])
AC_CHECK_HEADERS([gdiplus.h],
  [AC_LANG_PUSH(C++)
   AC_TRY_LINK(
     [#include <windows.h>
#include <gdiplus.h>],
     [Gdiplus::GdiplusStartupInput gdiplusStartupInput;],
     [sim_ac_have_gdiplus=true])
   AC_LANG_POP], [],
[#if HAVE_WINDOWS_H
# include <windows.h>
# endif
])
LIBS=$sim_ac_gdiplus_save_LIBS
if $sim_ac_have_gdiplus; then
  AC_MSG_RESULT([success ($sim_ac_gdiplus_libs)])
  $1
else
  AC_MSG_RESULT([failure])
  $2
fi
])
