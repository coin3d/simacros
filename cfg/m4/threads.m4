

AC_DEFUN([SIM_AC_SETUP_THREADS_API],
[
AC_ARG_ENABLE([threads],
  [AC_HELP_STRING([--enable-threads], [enable platform-independent multithreading abstraction classes])],
  [case $enableval in
  yes | true ) sim_ac_enable_threads=true ;;
  no | false ) sim_ac_enable_threads=false ;;
  *) AC_MSG_ERROR([invalid arg "$enableval" for --enable-threads option]) ;;
  esac],
  [sim_ac_enable_threads=true])

HAVE_THREADS=0

if $sim_ac_enable_threads; then

  sim_ac_threads_api="none"

  # Make it possible to explicitly turn off Win32 threads, to for instance
  # use POSIX threads instead under Win32.
  AC_ARG_ENABLE([w32threads],
    [AC_HELP_STRING([--disable-w32threads], [never use Win32 threads, even when available])],
    [case $enableval in
    yes | true ) sim_ac_w32_enable_threads=true ;;
    no | false ) sim_ac_w32_enable_threads=false ;;
    *) AC_MSG_ERROR([invalid arg "$enableval" for --disable-w32threads option]) ;;
    esac],
    [sim_ac_w32_enable_threads=true])

  sim_ac_win32_threads_available=false

  # Check for platform-native Win32 thread API first.
  if $sim_ac_w32_enable_threads; then
    AC_MSG_CHECKING([for Win32 threads])
    AC_TRY_LINK(
     [#include <windows.h>],
     [HANDLE h = CreateThread(NULL, 0, NULL, NULL, 0, NULL);
      (void)SetThreadPriority(h, 0);
      ExitThread(0);],
     [sim_ac_win32_threads_available=true
      sim_ac_threads_api="native Win32"
      AC_DEFINE([USE_W32THREAD], , [define to use the Win32 threads API])
      AC_DEFINE([COIN_THREADID_TYPE], DWORD, [System dependant thread ID type])])
      # (we just ignore failure, as we fall through to POSIX threads)
    AC_MSG_RESULT($sim_ac_win32_threads_available)
  fi
     
  if $sim_ac_win32_threads_available; then :; else
    SIM_AC_CHECK_PTHREAD([
      AC_DEFINE([USE_PTHREAD], , [define to use the POSIX threads API])
      AC_DEFINE([COIN_THREADID_TYPE], pthread_t, [System dependent thread ID type])
      sim_ac_threads_api="POSIX"
      COIN_EXTRA_CPPFLAGS="$COIN_EXTRA_CPPFLAGS $sim_ac_pthread_cppflags"
      COIN_EXTRA_LDFLAGS="$COIN_EXTRA_LDFLAGS $sim_ac_pthread_ldflags"
      COIN_EXTRA_LIBS="$sim_ac_pthread_libs $COIN_EXTRA_LIBS"
    ])
  fi

  if test "$sim_ac_threads_api" = "none"; then
    AC_MSG_ERROR([Could not find any usable native thread-handling API/library/devkit!  (If you do not want to enable the platform-independent thread-handling classes in Coin, specify the "--disable-threads" option to the configure script.)])
  fi

  HAVE_THREADS=1
  AC_DEFINE([HAVE_THREADS],, [to use the platform-independent thread-handling abstractions])
else
  sim_ac_threads_api="Disabled  (enable with --enable-threads)"
fi

AC_SUBST([HAVE_THREADS])
SIM_AC_CONFIGURATION_SETTING([System threads API], [$sim_ac_threads_api])

AM_CONDITIONAL([BUILD_WITH_THREADS], [$sim_ac_enable_threads])
])

