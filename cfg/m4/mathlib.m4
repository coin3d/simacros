############################################################################
# Usage:
#   SIM_AC_CHECK_MATHLIB([ACTION-IF-OK[, ACTION-IF-NOT-OK]])
#
# Description:
#   Check if linker needs to explicitly link with the library with
#   math functions. Sets environment variable $sim_ac_libm to the
#   necessary linklibrary, plus includes this library in the LIBS
#   env variable.
#
# Notes:
#   There is a macro AC_CHECK_LIBM in the libtool distribution, but it
#   does at least not work with SGI MIPSpro CC v7.30.
#
# Authors:
#   Lars Jørgen Aas, <larsa@sim.no>
#   Morten Eriksen, <mortene@sim.no>
#   Rupert Kittinger, <kittinger@mechanik.tu-graz.ac.at>
#

AC_DEFUN([SIM_AC_CHECK_MATHLIB],
[sim_ac_libm=

# It is on purpose that we avoid caching, as this macro could be
# run twice from the same configure-script: once for the C compiler,
# once for the C++ compiler.

AC_MSG_CHECKING(for math functions library)

sim_ac_mathlib_test=UNDEFINED
# BeOS and MSWin platforms has implicit math library linking,
# and ncr-sysv4.3 might use -lmw (according to AC_CHECK_LIBM in
# libtool.m4).
for sim_ac_math_chk in "" -lm -lmw; do
  if test x"$sim_ac_mathlib_test" = xUNDEFINED; then
    sim_ac_store_libs=$LIBS
    LIBS="$sim_ac_store_libs $sim_ac_math_chk"
    SIM_AC_MATHLIB_READY_IFELSE([sim_ac_mathlib_test=$sim_ac_math_chk])
    LIBS=$sim_ac_store_libs
  fi
done

if test x"$sim_ac_mathlib_test" != xUNDEFINED; then
  if test x"$sim_ac_mathlib_test" != x""; then
    sim_ac_libm=$sim_ac_mathlib_test
    LIBS="$sim_ac_libm $LIBS"
    AC_MSG_RESULT($sim_ac_mathlib_test)
  else
    AC_MSG_RESULT([no explicit linkage necessary])
  fi
  $1
else
  AC_MSG_RESULT([failed!])
  $2
fi
])# SIM_AC_CHECK_MATHLIB

# **************************************************************************
# SIM_AC_MATHLIB_READY_IFELSE( [ACTION-IF-TRUE], [ACTION-IF-FALSE] )

AC_DEFUN([SIM_AC_MATHLIB_READY_IFELSE],
[
# It is on purpose that we avoid caching, as this macro could be
# run twice from the same configure-script: once for the C compiler,
# once for the C++ compiler.

AC_TRY_LINK(
    [#include <math.h>
    #include <stdlib.h>
    #include <stdio.h>],
    [char s[16];
    /*
    SGI IRIX MIPSpro compilers may "fold" math
    functions with constant arguments already
    at compile time.

    It is also theoretically possible to do this
    for atof(), so to be _absolutely_ sure the
    math functions aren't replaced by constants at
    compile time, we get the arguments from a guaranteed
    non-constant source (stdin).
    */
    printf("> %g\n",fmod(atof(fgets(s,15,stdin)), atof(fgets(s,15,stdin))));
    printf("> %g\n",pow(atof(fgets(s,15,stdin)), atof(fgets(s,15,stdin))));
    printf("> %g\n",exp(atof(fgets(s,15,stdin))));
    printf("> %g\n",sin(atof(fgets(s,15,stdin))))],
    [sim_ac_mathlib_ready=true],
    [sim_ac_mathlib_ready=false])

if ${sim_ac_mathlib_ready}; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_MATHLIB_READY_IFELSE()

