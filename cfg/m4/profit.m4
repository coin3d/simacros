# **************************************************************************
# Usage:
#   SIM_AC_HAVE_PROFIT_IFELSE( IF-FOUND, IF-NOT-FOUND )
#
# Description:
#   This macro locates the profit development system.  If it is found,
#   the set of variables listed below are set up as described and made
#   available to the configure script.
#
# Autoconf Variables:
# < $sim_ac_profit_avail       true | false
# < $sim_ac_profit_cppflags    (extra flags the preprocessor needs)
# < $sim_ac_profit_ldflags     (extra flags the linker needs)
# < $sim_ac_profit_libs        (link library flags the linker needs)
#
# Authors:
#   Lars J. Aas <larsa@sim.no>
#
# TODO:
#

# **************************************************************************
# SIM_AC_TRY_LINK_PROFIT_IFELSE

AC_DEFUN([SIM_AC_TRY_LINK_PROFIT_IFELSE],
[
sim_ac_profit_save_LIBS=$LIBS
LIBS="-lprofit $LIBS"
AC_TRY_LINK(
  [#include <profit/profit.h>],
  [(void)prf_init();],
  [sim_ac_have_profit=true])
LIBS=$sim_ac_profit_save_LIBS

if $sim_ac_have_profit; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_TRY_LINK_PROFIT_IFELSE

# **************************************************************************
# SIM_AC_HAVE_PROFIT_IFELSE

AC_DEFUN([SIM_AC_HAVE_PROFIT_IFELSE],
[
sim_ac_have_profit=false
AC_MSG_CHECKING([profit (Open Flight support)])

SIM_AC_TRY_LINK_PROFIT_IFELSE([
  AC_MSG_RESULT([found])
  sim_ac_profit_cppflags=
  sim_ac_profit_ldflags=
  sim_ac_profit_libs=-lprofit
], [
  AC_MSG_RESULT([not found])
])
#  if x"$exec_prefix" != xNONE; then
#    sim_ac_save_CPPFLAGS=$CPPFLAGS
#    sim_ac_save_LDFLAGS=$LDFLAGS
#    sim_ac_save_LIBS=$LIBS
#    CPPFLAGS="-I$exec_prefix/include $CPPFLAGS"
#    LDFLAGS="-L$exec_prefix/lib $LDFLAGS"
# FIXME:
#    SIM_AC_TRY_LINK_PROFIT_IFELSE()
#    CPPFLAGS=$sim_ac_save_CPPFLAGS
#    LDFLAGS=$sim_ac_save_LDFLAGS
#  else
#  fi

if $sim_ac_have_profit; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi
]) # SIM_AC_HAVE_PROFIT_IFELSE

