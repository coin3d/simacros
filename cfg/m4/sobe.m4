# **************************************************************************
# SIM_AC_HAVE_SOBE_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Description:
#   This macro locates the SoBe development system.  If it is found, the
#   set of variables listed below are set up as described and made available
#   to the configure script.
#
# Autoconf Variables:
# > @sim_ac_sobe_desired     true | false (defaults to true)
# < $sim_ac_sobe_avail       true | false
# < $sim_ac_sobe_cppflags    extra flags the compiler needs
# < $sim_ac_sobe_ldflags     extra flags the linker needs
# < $sim_ac_sobe_libs        extra link libraries the linker needs
# < $sim_ac_sobe_version     version of SoBe
#
# Authors:
#   Lars J. Aas, <larsa@sim.no>
#   Morten Eriksen, <mortene@sim.no>
#

AC_DEFUN([SIM_AC_HAVE_SOBE_IFELSE], [
AC_PREREQ([2.14a])

AC_ARG_WITH(sobe, AC_HELP_STRING([--with-sobe=DIR], changequote({,}){set the prefix directory where SoBe resides [default=}sim4_sobe_with{]}changequote([,])), , [with_sobe=sim4_sobe_with])

sim_ac_sobe_avail=no

if test "x$with_sobe" != "xno"; then
  sim_ac_path=$PATH
  if test x"$with_sobe" != "xyes"; then
    sim_ac_path=${with_sobe}/bin:$PATH
    ifelse(sim4_sobe_searchprefix, yes,
    [if test "x$exec_prefix" != "xNONE"; then
      sim_ac_path=$sim_ac_path:${exec_prefix}/bin
    fi], :)
  fi

  AC_PATH_PROG(sim_ac_conf_cmd, sobe-config, false, $sim_ac_path)
  if test "x$sim_ac_conf_cmd" = "xfalse"; then
    AC_MSG_WARN(could not find 'sobe-config' in $sim_ac_path)
  fi

  sim_ac_sobe_cppflags=`$sim_ac_conf_cmd --cppflags`
  sim_ac_sobe_ldflags=`$sim_ac_conf_cmd --ldflags`
  sim_ac_sobe_libs=`$sim_ac_conf_cmd --libs`

  AC_CACHE_CHECK([whether the SoBe library is available],
    sim_cv_lib_sobe_avail, [
    sim_ac_save_cppflags=$CPPFLAGS
    sim_ac_save_ldflags=$LDFLAGS
    sim_ac_save_libs=$LIBS
    CPPFLAGS="$CPPFLAGS $sim_ac_sobe_cppflags"
    LDFLAGS="$LDFLAGS $sim_ac_sobe_ldflags"
    LIBS="$sim_ac_sobe_libs $LIBS"
    AC_TRY_LINK([#include <Inventor/Be/SoBe.h>],
                 [(void)SoBe::init((const char *)0L);],
                 sim_cv_lib_sobe_avail=yes,
                 sim_cv_lib_sobe_avail=no)
    CPPFLAGS=$sim_ac_save_cppflags
    LDFLAGS=$sim_ac_save_ldflags
    LIBS=$sim_ac_save_libs
  ])

  if test x"$sim_cv_lib_sobe_avail" = xyes; then
    sim_ac_sobe_avail=yes
    CPPFLAGS="$CPPFLAGS $sim_ac_sobe_cppflags"
    LDFLAGS="$LDFLAGS $sim_ac_sobe_ldflags"
    LIBS="$sim_ac_sobe_libs $LIBS"
    dnl execute ACTION-IF-FOUND
    ifelse($1, , :, $1)
  else
    dnl execute ACTION-IF-NOT-FOUND
    ifelse($2, , :, $2)
  fi
else
  dnl execute ACTION-IF-NOT-FOUND
  ifelse( $2, , :, $2)
fi
])

