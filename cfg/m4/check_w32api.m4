# **************************************************************************
# SIM_AC_CHECK_HEADER_TLHELP32_H:
#
#   Check for tlhelp32.h.

AC_DEFUN([SIM_AC_CHECK_HEADER_TLHELP32_H], [
# At least with MSVC++, these headers needs windows.h to have been included first.
AC_CHECK_HEADERS([tlhelp32.h], [], [], [
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
])
]) # SIM_AC_CHECK_HEADER_TLHELP32_H


# **************************************************************************
# SIM_AC_CHECK_FUNC__SPLITPATH:
#
#   Check for the _splitpath() macro/function.

AC_DEFUN([SIM_AC_CHECK_FUNC__SPLITPATH], [
AC_MSG_CHECKING([for _splitpath()])
AC_COMPILE_IFELSE(
[AC_LANG_PROGRAM([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif
#include <stdlib.h>
], [
  char filename[[100]];
  char drive[[100]];
  char dir[[100]];
  _splitpath(filename, drive, dir, NULL, NULL);
])], [
  AC_DEFINE([HAVE__SPLITPATH], 1, [define if the system has _splitpath()])
  AC_MSG_RESULT([found])
], [
  AC_MSG_RESULT([not found])
])
]) # SIM_AC_CHECK_FUNC__SPLITPATH


# **************************************************************************
# SIM_AC_CHECK_WIN32_API:
#
#   Check if the basic Win32 API is available.
#
#   Defines HAVE_WIN32_API, and sets sim_ac_have_win32_api to
#   either true or false.

AC_DEFUN([SIM_AC_CHECK_WIN32_API], [
sim_ac_have_win32_api=false
AC_MSG_CHECKING([if the Win32 API is available])
AC_COMPILE_IFELSE(
[AC_LANG_PROGRAM([
#include <windows.h>
],
[
  /* These need to be as basic as possible. I.e. they should be
     available on all Windows versions. That means NT 3.1 and later,
     Win95 and later, WinCE 1.0 and later), their definitions should
     be available from windows.h, and should be linked in from kernel32.

     The ones below are otherwise rather random picks.
  */
  (void)CreateDirectory(NULL, NULL);
  (void)RemoveDirectory(NULL);
  SetLastError(0);
  (void)GetLastError();
  (void)LocalAlloc(0, 1);
  (void)LocalFree(NULL);
  return 0;
])],
[sim_ac_have_win32_api=true])

if $sim_ac_have_win32_api; then
  AC_DEFINE([HAVE_WIN32_API], [1], [Define if the Win32 API is available])
  AC_MSG_RESULT([yes])
else
  AC_MSG_RESULT([no])
fi
]) # SIM_AC_CHECK_WIN32_API

