############################################################################
# Usage:
#   SIM_AC_CHECK_VAR_FUNCTIONNAME
#
# Side-Effects:
#   config.h:
#     HAVE_VAR___func__              (1 if exists)
#     HAVE_VAR___PRETTY_FUNCTION__   (1 if exists)
#     HAVE_VAR___FUNCTION__          (1 if exists)
#
# (Note that only one of these will be defined.)
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#   Morten Eriksen <mortene@sim.no>

AC_DEFUN([SIM_AC_CHECK_VAR_FUNCTIONNAME], [
AC_CACHE_CHECK([for function name variable],
  sim_cv_var_functionname, [
  # __func__ is the identifier used by compilers which are
  # compliant with the C99 ISO/IEC 9899:1999 standard.
  AC_TRY_COMPILE(
    [#include <stdio.h>],
    [(void)printf("%s\n",__func__)],
    [sim_cv_var_functionname=__func__],
    [sim_cv_var_functionname=none])
  if test x"$sim_cv_var_functionname" = x"none"; then
    # GCC uses __PRETTY_FUNCTION__
    AC_TRY_COMPILE(
      [#include <stdio.h>],
      [(void)printf("%s\n",__PRETTY_FUNCTION__)],
      [sim_cv_var_functionname=__PRETTY_FUNCTION__],
      [sim_cv_var_functionname=none])
  fi
  if test x"$sim_cv_var_functionname" = x"none"; then
    AC_TRY_COMPILE(
      [#include <stdio.h>],
      [(void)printf("%s\n",__FUNCTION__)],
      [sim_cv_var_functionname=__FUNCTION__],
      [sim_cv_var_functionname=none])
  fi])

# FIXME: these can probably be contracted to a single test inside a loop.
# 20010330 mortene.

if test x"$sim_cv_var_functionname" = x"__func__"; then
  AC_DEFINE([HAVE_VAR___func__], 1,
    [Define this to true if the __func__ variable contains the current function name])
fi

if test x"$sim_cv_var_functionname" = x"__PRETTY_FUNCTION__"; then
  AC_DEFINE([HAVE_VAR___PRETTY_FUNCTION__], 1,
    [Define this to true if the __PRETTY_FUNCTION__ variable contains the current function name])
fi

if test x"$sim_cv_var_functionname" = x"__FUNCTION__"; then
  AC_DEFINE([HAVE_VAR___FUNCTION__], 1,
    [Define this to true if the __FUNCTION__ variable contains the current function name])
fi
])

