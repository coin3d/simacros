# SIM_AC_CHECK_DL([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
# ----------------------------------------------------------
#
#  Try to find the dynamic link loader library. If it is found, these
#  shell variables are set:
#
#    $sim_ac_dl_cppflags (extra flags the compiler needs for dl lib)
#    $sim_ac_dl_ldflags  (extra flags the linker needs for dl lib)
#    $sim_ac_dl_libs     (link libraries the linker needs for dl lib)
#
#  The CPPFLAGS, LDFLAGS and LIBS flags will also be modified accordingly.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_DL], [
AC_ARG_WITH(
  [dl],
  [AC_HELP_STRING(
    [--with-dl=DIR],
    [include support for the dynamic link loader library [default=yes]])],
  [],
  [with_dl=yes])

if test x"$with_dl" != xno; then
  if test x"$with_dl" != xyes; then
    sim_ac_dl_cppflags="-I${with_dl}/include"
    sim_ac_dl_ldflags="-L${with_dl}/lib"
  fi

  sim_ac_save_cppflags=$CPPFLAGS
  sim_ac_save_ldflags=$LDFLAGS
  sim_ac_save_libs=$LIBS

  CPPFLAGS="$CPPFLAGS $sim_ac_dl_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_dl_ldflags"

  # Use SIM_AC_CHECK_HEADERS instead of .._HEADER to get the
  # HAVE_DLFCN_H symbol set up in config.h automatically.
  AC_CHECK_HEADERS([dlfcn.h])

  sim_ac_dl_avail=false

  AC_MSG_CHECKING([for the dl library])
  # At least under FreeBSD, dlopen() et al is part of the C library.
  # On HP-UX, dlopen() might reside in a library "svld" instead of "dl".
  for sim_ac_dl_libcheck in "" "-ldl" "-lsvld"; do
    if $sim_ac_dl_avail; then :; else
      LIBS="$sim_ac_dl_libcheck $sim_ac_save_libs"
      AC_TRY_LINK([
#ifdef HAVE_DLFCN_H
#include <dlfcn.h>
#endif /* HAVE_DLFCN_H */
],
                  [(void)dlopen(0L, 0); (void)dlsym(0L, "Gunners!"); (void)dlclose(0L);],
                  [sim_ac_dl_avail=true
                   sim_ac_dl_libs="$sim_ac_dl_libcheck"
                  ])
    fi
  done

  if $sim_ac_dl_avail; then
    if test x"$sim_ac_dl_libs" = x""; then
      AC_MSG_RESULT(yes)
    else
      AC_MSG_RESULT($sim_ac_dl_cppflags $sim_ac_dl_ldflags $sim_ac_dl_libs)
    fi
  else
    AC_MSG_RESULT(not available)
  fi

  if $sim_ac_dl_avail; then
    ifelse([$1], , :, [$1])
  else
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
    ifelse([$2], , :, [$2])
  fi
fi
])

# SIM_AC_CHECK_LOADLIBRARY([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
# -------------------------------------------------------------------
#
#  Try to use the Win32 dynamic link loader methods LoadLibrary(),
#  GetProcAddress() and FreeLibrary().
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_LOADLIBRARY], [
AC_ARG_ENABLE(
  [loadlibrary],
  [AC_HELP_STRING([--disable-loadlibrary], [don't use run-time link bindings under Win32])],
  [case $enableval in
  yes | true ) sim_ac_win32_loadlibrary=true ;;
  *) sim_ac_win32_loadlibrary=false ;;
  esac],
  [sim_ac_win32_loadlibrary=true])

if $sim_ac_win32_loadlibrary; then
  # Use SIM_AC_CHECK_HEADERS instead of .._HEADER to get the
  # HAVE_DLFCN_H symbol set up in config.h automatically.
  AC_CHECK_HEADERS([windows.h])

  AC_CACHE_CHECK([whether the Win32 LoadLibrary() method is available],
    sim_cv_lib_loadlibrary_avail,
    [AC_TRY_LINK([
#ifdef HAVE_WINDOWS_H
#include <windows.h>
#endif /* HAVE_WINDOWS_H */
],
                 [(void)LoadLibrary(0L); (void)GetProcAddress(0L, 0L); (void)FreeLibrary(0L); ],
                 [sim_cv_lib_loadlibrary_avail=yes],
                 [sim_cv_lib_loadlibrary_avail=no])])

  if test x"$sim_cv_lib_loadlibrary_avail" = xyes; then
    ifelse([$1], , :, [$1])
  else
    ifelse([$2], , :, [$2])
  fi
fi
])

# SIM_AC_CHECK_DLD([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
# ----------------------------------------------------------
#
#  Try to find the dynamic link loader library available on HP-UX 10.
#  If it is found, this shell variable is set:
#
#    $sim_ac_dld_libs     (link libraries the linker needs for dld lib)
#
#  The $LIBS var will also be modified accordingly.
#
# Author: Morten Eriksen, <mortene@sim.no>.

AC_DEFUN([SIM_AC_CHECK_DLD], [
  sim_ac_dld_libs="-ldld"

  sim_ac_save_libs=$LIBS
  LIBS="$sim_ac_dld_libs $LIBS"

  AC_CACHE_CHECK([whether the DLD shared library loader is available],
    sim_cv_lib_dld_avail,
    [AC_TRY_LINK([#include <dl.h>],
                 [(void)shl_load("allyourbase", 0, 0L); (void)shl_findsym(0L, "arebelongtous", 0, 0L); (void)shl_unload((shl_t)0);],
                 [sim_cv_lib_dld_avail=yes],
                 [sim_cv_lib_dld_avail=no])])

  if test x"$sim_cv_lib_dld_avail" = xyes; then
    ifelse([$1], , :, [$1])
  else
    LIBS=$sim_ac_save_libs
    ifelse([$2], , :, [$2])
  fi
])


# SIM_AC_CHECK_DYLD([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
# -------------------------------------------------------------------
#
#  Try to use the Mac OS X dynamik link editor method
#  NSLookupAndBindSymbol()
#
# Author: Karin Kosina, <kyrah@sim.no>

AC_DEFUN([SIM_AC_CHECK_DYLD], [
AC_ARG_ENABLE(
  [dyld],
  [AC_HELP_STRING([--disable-dyld],
                  [don't use run-time link bindings under Mac OS X])],
  [case $enableval in
  yes | true ) sim_ac_dyld=true ;;
  *) sim_ac_dyld=false ;;
  esac],
  [sim_ac_dyld=true])

if $sim_ac_dyld; then

  AC_CHECK_HEADERS([mach-o/dyld.h])

  AC_CACHE_CHECK([whether we can use Mach-O dyld],
    sim_cv_dyld_avail,
    [AC_TRY_LINK([
#ifdef HAVE_MACH_O_DYLD_H
#include <mach-o/dyld.h>
#endif /* HAVE_MACH_O_DYLD_H */
],
                 [(void)NSLookupAndBindSymbol("foo");],
                 [sim_cv_dyld_avail=yes],
                 [sim_cv_dyld_avail=no])])

  if test x"$sim_cv_dyld_avail" = xyes; then
    ifelse([$1], , :, [$1])
  else
    ifelse([$2], , :, [$2])
  fi
fi
])
