############################################################################
# Usage:
#   SIM_AC_HAVE_SOMAC_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Description:
#   This macro locates the SoMac development system.  If it is found,
#   the set of variables listed below are set up as described and made
#   available to the configure script.
#
#   The $sim_ac_somac_desired variable can be set to false externally to
#   make SoMac default to be excluded.
#
# Autoconf Variables:
# > $sim_ac_somac_desired     true | false (defaults to true)
# < $sim_ac_somac_avail       true | false
# < $sim_ac_somac_cppflags    (extra flags the preprocessor needs)
# < $sim_ac_somac_ldflags     (extra flags the linker needs)
# < $sim_ac_somac_libs        (link library flags the linker needs)
# < $sim_ac_somac_datadir     (location of SoMac data files)
# < $sim_ac_somac_version     (the libSoMac version)
#
# Authors:
#   Lars J. Aas, <larsa@sim.no>
#   Morten Eriksen, <mortene@sim.no>
#
# TODO:
#

AC_DEFUN([SIM_AC_HAVE_SOMAC_IFELSE], [
AC_PREREQ([2.14a])

# official variables
sim_ac_somac_avail=false
sim_ac_somac_cppflags=
sim_ac_somac_ldflags=
sim_ac_somac_libs=
sim_ac_somac_datadir=
sim_ac_somac_version=

# internal variables
: ${sim_ac_somac_desired=true}
sim_ac_somac_extrapath=

AC_ARG_WITH([somac], AC_HELP_STRING([--without-somac], [disable use of SoMac]))
AC_ARG_WITH([somac], AC_HELP_STRING([--with-somac], [enable use of SoMac]))
AC_ARG_WITH([somac],
  AC_HELP_STRING([--with-somac=DIR], [give prefix location of SoMac]),
  [ case $withval in
    no)  sim_ac_somac_desired=false ;;
    yes) sim_ac_somac_desired=true ;;
    *)   sim_ac_somac_desired=true
         sim_ac_somac_extrapath=$withval ;;
    esac],
  [])

if $sim_ac_somac_desired; then
  sim_ac_path=$PATH
  test -z "$sim_ac_somac_extrapath" ||   ## search in --with-somac path
    sim_ac_path=$sim_ac_somac_extrapath/bin:$sim_ac_path
  test x"$prefix" = xNONE ||          ## search in --prefix path
    sim_ac_path=$sim_ac_path:$prefix/bin

  AC_PATH_PROG(sim_ac_somac_configcmd, somac-config, false, $sim_ac_path)
  if $sim_ac_somac_configcmd; then
    sim_ac_somac_cppflags=`$sim_ac_somac_configcmd --cppflags`
    sim_ac_somac_ldflags=`$sim_ac_somac_configcmd --ldflags`
    sim_ac_somac_libs=`$sim_ac_somac_configcmd --libs`
    sim_ac_somac_datadir=`$sim_ac_somac_configcmd --datadir`
    sim_ac_somac_version=`$sim_ac_somac_configcmd --version`
    AC_CACHE_CHECK(
      [whether libSoMac is available],
      sim_cv_somac_avail,
      [sim_ac_save_cppflags=$CPPFLAGS
      sim_ac_save_ldflags=$LDFLAGS
      sim_ac_save_libs=$LIBS
      CPPFLAGS="$CPPFLAGS $sim_ac_somac_cppflags"
      LDFLAGS="$LDFLAGS $sim_ac_somac_ldflags"
      LIBS="$sim_ac_somac_libs $LIBS"
      AC_LANG_PUSH(C++)
      AC_TRY_LINK(
        [#include <Inventor/Mac/SoMac.h>],
        [(void)SoMac::init((const char *)0L);],
        [sim_cv_somac_avail=true],
        [sim_cv_somac_avail=false])
      AC_LANG_POP
      CPPFLAGS=$sim_ac_save_cppflags
      LDFLAGS=$sim_ac_save_ldflags
      LIBS=$sim_ac_save_libs
    ])
    sim_ac_somac_avail=$sim_cv_somac_avail
  else
    locations=`IFS=:; for p in $sim_ac_path; do echo " -> $p/somac-config"; done`
    AC_MSG_WARN([cannot find 'somac-config' at any of these locations:
$locations])
  fi
fi

if $sim_ac_somac_avail; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_SOMAC_IFELSE()

