############################################################################
# Usage:
#   SIM_AC_COMPILER_FUNCTIONNAME_VAR(compiler-id)
#
# Side-effects, defines these in config.h:
#
#     HAVE_$compilerid_VAR___func__              (1 if exists)
#     HAVE_$compilerid_VAR___PRETTY_FUNCTION__   (1 if exists)
#     HAVE_$compilerid_VAR___FUNCTION__          (1 if exists)
#
# (Note that only one of these will be defined.)
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#   Morten Eriksen <mortene@sim.no>

AC_DEFUN([SIM_AC_COMPILER_FUNCTIONNAME_VAR], [
AC_MSG_CHECKING([for function name variable for $1 compiler])
sim_ac_var_functionname=

# * __func__ is the identifier used by compilers which are
#   compliant with the C99 ISO/IEC 9899:1999 standard.
#
# * GCC uses __PRETTY_FUNCTION__
#
# * FIXME: why was __FUNCTION__ added? for SGI MIPSpro, perhaps?
#   20040902 mortene.

for i in "__func__" "__PRETTY_FUNCTION__" "__FUNCTION__"; do
if test -z "$sim_ac_var_functionname"; then
  AC_TRY_COMPILE(
    [#include <stdio.h>],
    [(void)printf("%s\n", $i)],
    [sim_ac_var_functionname=$i]
  )
fi
done

if test -z "$sim_ac_var_functionname"; then
  AC_MSG_RESULT(none)
else
  AC_MSG_RESULT($sim_ac_var_functionname)
  AC_DEFINE_UNQUOTED(HAVE_$1_COMPILER_FUNCTION_NAME_VAR,
                     $sim_ac_var_functionname,
                     [The $1 compiler has a variable containing the current function name])
fi
])


############################################################################
# Usage:
#   SIM_AC_CHECK_VAR_FUNCTIONNAME
#
# Convenience wrapper for the above function.
AC_DEFUN([SIM_AC_CHECK_VAR_FUNCTIONNAME], [
  AC_LANG_PUSH(C++)
  SIM_AC_COMPILER_FUNCTIONNAME_VAR(CPP)
  AC_LANG_POP(C++)
  AC_LANG_PUSH(C)
  SIM_AC_COMPILER_FUNCTIONNAME_VAR(C)
  AC_LANG_POP(C)
])
