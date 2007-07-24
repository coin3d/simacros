# **************************************************************************
# SIM_AC_HAVE_GDIPLUS_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Variables:
#   sim_ac_have_gdiplus
#   sim_ac_gdiplus_libs
#
# Authors:
#   Tamer Fahmy <tamer@sim.no>

AC_DEFUN([SIM_AC_HAVE_GDIPLUS_IFELSE], [
AC_CHECK_HEADERS([windows.h], , AC_ERROR([no windows.h]))
: ${sim_ac_have_gdiplus=false}
$sim_ac_have_gdiplus && break
sim_ac_gdiplus_save_CPPFLAGS=$CPPFLAGS
sim_ac_gdiplus_save_LDFLAGS=$LDFLAGS
sim_ac_gdiplus_save_LIBS=$LIBS

if test X"$sim_ac_gdiplus_path" = X""; then
  sim_ac_gdiplus_LIBS="-lgdiplus"
  LIBS="$sim_ac_gdiplus_LIBS $LIBS"
else
  sim_ac_gdiplus_CPPFLAGS="-I$sim_ac_gdiplus_path/include -I$sim_ac_gdiplus_path/includes"
  sim_ac_gdiplus_LDFLAGS="-L$sim_ac_gdiplus_path/lib"
  sim_ac_gdiplus_LIBS="-lgdiplus"
  CPPFLAGS="$sim_ac_gdiplus_CPPFLAGS $CPPFLAGS"
  LDFLAGS="$sim_ac_gdiplus_LDFLAGS $LDFLAGS"
  LIBS="$sim_ac_gdiplus_LIBS $LIBS"
fi

AC_LANG_PUSH([C++])
AC_CHECK_HEADERS([gdiplus.h], sim_ac_have_gdiplus_h=true, sim_ac_have_gdiplus_h=false, [
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
/* MSVC6 fix for gdiplus.h */
#if defined(_MSC_VER) && (_MSC_VER == 1200) && !defined(ULONG_PTR)
#define ULONG_PTR ULONG /* (32bit build) */
#endif /* MSVC6 */
])
AC_LANG_POP

if $sim_ac_have_gdiplus_h; then
  AC_MSG_CHECKING([for GDI+])
  AC_LANG_PUSH([C++])
  AC_TRY_LINK([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
/* MSVC6 fix for gdiplus.h */
#if defined(_MSC_VER) && (_MSC_VER == 1200) && !defined(ULONG_PTR)
#define ULONG_PTR ULONG /* (32bit build) */
#endif /* MSVC6 */
#include <gdiplus.h>
  ], [
    Gdiplus::GdiplusStartupInput gdiplusStartupInput;
  ], [
    sim_ac_have_gdiplus=true
  ])
  AC_LANG_POP

  if $sim_ac_have_gdiplus; then
    AC_MSG_RESULT([success ($sim_ac_gdiplus_LIBS)])
  else
    AC_MSG_RESULT([failure])
  fi


  if $sim_ac_have_gdiplus; then
    AC_LANG_PUSH([C++])
    AC_MSG_CHECKING([GDI+ LockBits() signature anomaly])
    AC_TRY_COMPILE([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
/* MSVC6 fix for gdiplus.h */
#if defined(_MSC_VER) && (_MSC_VER == 1200) && !defined(ULONG_PTR)
#define ULONG_PTR ULONG /* (32bit build) */
#endif /* MSVC6 */
#include <gdiplus.h>
    ], [
      Gdiplus::Bitmap * bitmap = NULL;
      Gdiplus::BitmapData bitmapData;
      Gdiplus::Rect rect(0, 0, 100, 100);
      Gdiplus::Status result = bitmap->LockBits(&rect, Gdiplus::ImageLockModeRead,
                                                PixelFormat32bppARGB, &bitmapData);
    ], [
      AC_MSG_RESULT([Rect arg is pointer])
      AC_DEFINE([HAVE_GDIPLUS_LOCKBITS_RECTARG_POINTER], [1],
        [Define if first argument of Gdiplus::Bitmap::LockBits() is a pointer])
    ], [
      AC_MSG_RESULT([Rect arg is reference])
    ])
    AC_LANG_POP
  fi

  CPPFLAGS=$sim_ac_gdiplus_save_CPPFLAGS
  LDFLAGS=$sim_ac_gdiplus_save_LDFLAGS
  LIBS=$sim_ac_gdiplus_save_LIBS
  if $sim_ac_have_gdiplus; then
    :
    $1
  else
    :
    $2
  fi

else
  CPPFLAGS=$sim_ac_gdiplus_save_CPPFLAGS
  LDFLAGS=$sim_ac_gdiplus_save_LDFLAGS
  LIBS=$sim_ac_gdiplus_save_LIBS
  :
  $2
fi
])
