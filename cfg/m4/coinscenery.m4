############################################################################
# Usage:
#   SIM_AC_HAVE_COINSCENERY_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Description:
#   This macro locates the library of Coin Scenery bindings.  If it is found,
#   the set of variables listed below are set up as described and made
#   available to the configure script.
#
#   The $sim_ac_coinscenery_desired variable can be set to false externally to
#   make libcoinscenery default to be excluded.
#
# Autoconf Variables:
# > $sim_ac_coinscenery_desired     true | false (defaults to false)
# < $sim_ac_coinscenery_avail       true | false
# < $sim_ac_coinscenery_cppflags    (extra flags the preprocessor needs)
# < $sim_ac_coinscenery_cflags      (extra flags the C compiler needs)
# < $sim_ac_coinscenery_cxxflags    (extra flags the C++ compiler needs)
# < $sim_ac_coinscenery_ldflags     (extra flags the linker needs)
# < $sim_ac_coinscenery_libs        (link library flags the linker needs)
# < $sim_ac_coinscenery_includedir  (location of coinscenery headers)
# < $sim_ac_coinscenery_version     (the libcoinscenery version)
# < $sim_ac_coinscenery_msvcrt      (the MSVC++ C library coinscenery was built with)
# < $sim_ac_coinscenery_configcmd   (the path to coinscenery-config or "false")
#
# Authors:
#   Lars J. Aas, <larsa@sim.no>
#   Morten Eriksen, <mortene@sim.no>
#
# FIXME: just a blanket copy of SIM_AC_HAVE_SMALLCHANGE_IFELSE with
# a simple search'n'replace job, this. Should clean up, removing the parts
# inappropriate and not relevant for libcoinscenery. 20040917 mortene.

AC_DEFUN([SIM_AC_HAVE_COINSCENERY_IFELSE], [
AC_PREREQ([2.14a])

# official variables
sim_ac_coinscenery_avail=false
sim_ac_coinscenery_cppflags=
sim_ac_coinscenery_cflags=
sim_ac_coinscenery_cxxflags=
sim_ac_coinscenery_ldflags=
sim_ac_coinscenery_libs=
sim_ac_coinscenery_includedir=
sim_ac_coinscenery_version=

# internal variables
: ${sim_ac_coinscenery_desired=true}
sim_ac_coinscenery_extrapath=

AC_ARG_WITH([coinscenery],
AC_HELP_STRING([--with-coinscenery], [enable use of coinscenery [[default=no]]])
AC_HELP_STRING([--with-coinscenery=DIR], [give prefix location of coinscenery]),
  [ case $withval in
    no)  sim_ac_coinscenery_desired=false ;;
    yes) sim_ac_coinscenery_desired=true ;;
    *)   sim_ac_coinscenery_desired=false
         sim_ac_coinscenery_extrapath=$withval ;;
    esac],
  [])

case $build in
*-mks ) sim_ac_pathsep=";" ;;
* )     sim_ac_pathsep="${PATH_SEPARATOR}" ;;
esac

if $sim_ac_coinscenery_desired; then
  sim_ac_path=$PATH
  test -z "$sim_ac_coinscenery_extrapath" || ## search in --with-coinscenery path
    sim_ac_path="$sim_ac_coinscenery_extrapath/bin${sim_ac_pathsep}$sim_ac_path"
  test x"$prefix" = xNONE ||          ## search in --prefix path
    sim_ac_path="$sim_ac_path${sim_ac_pathsep}$prefix/bin"

  AC_PATH_PROG(sim_ac_coinscenery_configcmd, coinscenery-config, false, $sim_ac_path)

  if ! test "X$sim_ac_coinscenery_configcmd" = "Xfalse"; then
    test -n "$CONFIG" &&
      $sim_ac_coinscenery_configcmd --alternate=$CONFIG >/dev/null 2>/dev/null &&
      sim_ac_coinscenery_configcmd="$sim_ac_coinscenery_configcmd --alternate=$CONFIG"
  fi

  if $sim_ac_coinscenery_configcmd; then
    sim_ac_coinscenery_version=`$sim_ac_coinscenery_configcmd --version`
    sim_ac_coinscenery_cppflags=`$sim_ac_coinscenery_configcmd --cppflags`
    sim_ac_coinscenery_cflags=`$sim_ac_coinscenery_configcmd --cflags 2>/dev/null`
    sim_ac_coinscenery_cxxflags=`$sim_ac_coinscenery_configcmd --cxxflags`
    sim_ac_coinscenery_ldflags=`$sim_ac_coinscenery_configcmd --ldflags`
    sim_ac_coinscenery_libs=`$sim_ac_coinscenery_configcmd --libs`
    # Hide stderr on the following, as ``--includedir'', ``--msvcrt''
    # and ``--cflags'' options were added late to coinscenery-config.
    sim_ac_coinscenery_includedir=`$sim_ac_coinscenery_configcmd --includedir 2>/dev/null`
    sim_ac_coinscenery_msvcrt=`$sim_ac_coinscenery_configcmd --msvcrt 2>/dev/null`
    sim_ac_coinscenery_cflags=`$sim_ac_coinscenery_configcmd --cflags 2>/dev/null`
    AC_CACHE_CHECK(
      [whether libcoinscenery is available],
      sim_cv_coinscenery_avail,
      [sim_ac_save_cppflags=$CPPFLAGS
      sim_ac_save_ldflags=$LDFLAGS
      sim_ac_save_libs=$LIBS
      CPPFLAGS="$CPPFLAGS $sim_ac_coinscenery_cppflags"
      LDFLAGS="$LDFLAGS $sim_ac_coinscenery_ldflags"
      LIBS="$sim_ac_coinscenery_libs $LIBS"
      AC_LANG_PUSH(C++)
      AC_TRY_LINK(
        [#include <sim/coinscenery/SmScenery.h>],
        [SmScenery::initClasses();],
        [sim_cv_coinscenery_avail=true],
        [sim_cv_coinscenery_avail=false])
      AC_LANG_POP
      CPPFLAGS=$sim_ac_save_cppflags
      LDFLAGS=$sim_ac_save_ldflags
      LIBS=$sim_ac_save_libs
    ])
    sim_ac_coinscenery_avail=$sim_cv_coinscenery_avail
  else
    locations=`IFS="${sim_ac_pathsep}"; for p in $sim_ac_path; do echo " -> $p/coinscenery-config"; done`
    AC_MSG_WARN([cannot find 'coinscenery-config' at any of these locations:
$locations])
  fi
fi

if $sim_ac_coinscenery_avail; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_COINSCENERY_IFELSE()

