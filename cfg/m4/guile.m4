# **************************************************************************
# This is a set of replacement macros for the poor GUILE_FLAGS macro that
# is provided with Guile.
#
# Authors:
#   Lars J. Aas <larsa@sim.no>

# **************************************************************************
# SIM_AC_HAVE_GUILE_IFELSE( [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND] )
#
# Detect if Guile is installed on the system.
#
# TODO: check for header files, and try to like a piece against Guile.

AC_DEFUN([SIM_AC_HAVE_GUILE_IFELSE], [

AC_ARG_WITH(
  [guile],
  AC_HELP_STRING([--with-guile=PATH], [set path to (or disable) Guile]),
  [case $withval in
  no)  sim_ac_want_guile=false ;;
  yes) sim_ac_want_guile=true ;;
  *)   sim_ac_want_guile=true; sim_ac_guile_extrapath=$withval ;;
  esac])

if ${sim_ac_want_guile=true}; then
  sim_ac_guile_path=$PATH
  test x${sim_ac_guile_extrapath+SET} = xSET &&
    sim_ac_guile_path=$sim_ac_guile_extrapath:$sim_ac_guile_path
  test x${exec_prefix} != xNONE &&
    sim_ac_guile_path=$sim_ac_guile_path:$exec_prefix/bin
  AC_PATH_PROG(sim_ac_guile, guile, false, $sim_ac_guile_path)
  if $sim_ac_guile -q -c "(quit)"; then
    sim_ac_have_guile=true
    sim_ac_guile_cppflags=-I`$sim_ac_guile -q -c \
      "(display (cdr (assq 'includedir %guile-build-info)))"`
    sim_ac_guile_ldflags=-L`$sim_ac_guile -q -c \
      "(display (cdr (assq 'libdir %guile-build-info)))"`
    sim_ac_guile_libs=`$sim_ac_guile -q -c \
      "(display (cdr (assq 'LIBS %guile-build-info)))"`
    sim_ac_guile_libs="-lguile $sim_ac_guile_libs"
  fi
fi

if ${sim_ac_want_guile=true}; then
  if ${sim_ac_have_guile=false}; then
    ifelse([$1], , :, [$1])
  else
    ifelse([$2], , :, [$2])
  fi
else
  # Guile disabled
  ifelse([$2], , :, [$2])
fi

]) # SIM_AC_HAVE_GUILE_IFELSE

# **************************************************************************
# SIM_AC_HAVE_GUILE_GOOPS_IFELSE( [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND] )
#
# Detect if Goops is installed on the system.
#
# TODO: ensure that Goops is usable from Guile.

AC_DEFUN([SIM_AC_HAVE_GUILE_GOOPS_IFELSE], [
AC_REQUIRE([SIM_AC_HAVE_GUILE_IFELSE])

AC_MSG_CHECKING([for guile goops])

if ${sim_ac_want_goops=true}; then
  if ${sim_ac_have_guile=false}; then
    sim_ac_guile_pkgdatadir=`$sim_ac_guile -q -c \
      "(display (cdr (assq 'pkgdatadir %guile-build-info)))"`
    test -f $sim_ac_guile_pkgdatadir/oop/goops.scm &&
      sim_ac_have_guile_goops=true
  fi
fi

if ${sim_ac_want_goops=true}; then
  if ${sim_ac_have_guile_goops=false}; then
    AC_MSG_RESULT([found])
    ifelse([$1], , :, [$1])
  else
    AC_MSG_RESULT([not found])
    ifelse([$2], , :, [$2])
  fi
else
  AC_MSG_RESULT([disabled])
  ifelse([$2], , :, [$2])
fi

]) # SIM_AC_HAVE_GUILE_GOOPS_IFELSE

AC_DEFUN([SIM_AC_HAVE_LIBGUILE_IFELSE],
[: ${sim_ac_have_libguile=false}
AC_MSG_CHECKING([for guile])
AC_ARG_WITH(
  [guile],
  [AC_HELP_STRING([--with-guile=PATH], [enable/disable guile support])],
  [case $withval in
  yes | "") sim_ac_want_libguile=true ;;
  no)       sim_ac_want_libguile=false ;;
  *)        sim_ac_want_libguile=true
            sim_ac_libguile_path=$withval ;;
  esac],
  [sim_ac_want_libguile=true])
case $sim_ac_want_libguile in
true)
  $sim_ac_have_libguile && break
  sim_ac_libguile_save_CPPFLAGS=$CPPFLAGS
  sim_ac_libguile_save_LDFLAGS=$LDFLAGS
  sim_ac_libguile_save_LIBS=$LIBS
  sim_ac_libguile_debug=false
  test -n "`echo -- $CPPFLAGS $CFLAGS $CXXFLAGS | grep -- '-g\\>'`" &&
    sim_ac_libguile_debug=true
  # test -z "$sim_ac_libguile_path" -a x"$prefix" != xNONE &&
  #   sim_ac_libguile_path=$prefix
  sim_ac_libguile_name=guile
  if test -n "$sim_ac_libguile_path"; then
    for sim_ac_libguile_candidate in \
      `( ls $sim_ac_libguile_path/lib/guile*.lib;
         ls $sim_ac_libguile_path/lib/guile*d.lib ) 2>/dev/null`
    do
      case $sim_ac_libguile_candidate in
      *d.lib)
        $sim_ac_libguile_debug &&
          sim_ac_libguile_name=`basename $sim_ac_libguile_candidate .lib` ;;
      *.lib)
        sim_ac_libguile_name=`basename $sim_ac_libguile_candidate .lib` ;;
      esac
    done
    sim_ac_libguile_cppflags="-I$sim_ac_libguile_path/include"
    CPPFLAGS="$CPPFLAGS $sim_ac_libguile_cppflags"
    sim_ac_libguile_ldflags="-L$sim_ac_libguile_path/lib"
    LDFLAGS="$LDFLAGS $sim_ac_libguile_ldflags"
    # unset sim_ac_libguile_candidate
    # unset sim_ac_libguile_path
  fi
  sim_ac_libguile_libs="-l$sim_ac_libguile_name"
  LIBS="$sim_ac_libguile_libs $LIBS"
  AC_TRY_LINK(
    [#include <guile/gh.h>],
    [scm_initialized_p = 0; gh_enter(0, (char**)0, (void (*)(int, char**)) 0)],
    [sim_ac_have_libguile=true])
  if test x"${sim_ac_have_libguile}" = x"false"; then
    CPPFLAGS="$CPPFLAGS -DGUILE_DLL"
    sim_ac_libguile_cppflags="$sim_ac_libguile_cppflags -DGUILE_DLL"
    AC_TRY_LINK(
      [#include <guile/gh.h>],
      [scm_initialized_p = 0; gh_enter(0, (char**)0, (void (*)(int, char**)) 0)],
      [sim_ac_have_libguile=true])
  fi
  CPPFLAGS=$sim_ac_libguile_save_CPPFLAGS
  LDFLAGS=$sim_ac_libguile_save_LDFLAGS
  LIBS=$sim_ac_libguile_save_LIBS

  # unset sim_ac_libguile_debug
  # unset sim_ac_libguile_name
  # unset sim_ac_libguile_save_CPPFLAGS
  # unset sim_ac_libguile_save_LDFLAGS
  # unset sim_ac_libguile_save_LIBS
  ;;
esac
if $sim_ac_want_libguile; then
  if $sim_ac_have_libguile; then
    AC_MSG_RESULT([success ($sim_ac_libguile_cppflags $sim_ac_libguile_libs)])
    $1
  else
    AC_MSG_RESULT([failure])
    $2
  fi
else
  AC_MSG_RESULT([disabled])
  $2
fi
# unset sim_ac_want_libguile
])

