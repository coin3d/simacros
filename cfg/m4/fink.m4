# **************************************************************************
# Usage:
#   SIM_AC_CHECK_FINK ([ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]])
#
# Description:
#   This macro checks for the availability of the Fink system. Fink is 
#   dpkg-based distribution of UNIX tools for Mac OS X that installs
#   libraries and headers into /sw.
#
# Autoconf Variables:
#     $sim_ac_fink_avail       true | false
#     $sim_ac_fink_cppflags    (extra flags the preprocessor needs)
#     $sim_ac_fink_ldflags     (extra flags the linker needs)
#
# CPPFLAGS and LDFLAGS will also be set accordingly.
#
# Authors:
#   Karin Kosina <kyrah@sim.no>
#

AC_DEFUN([SIM_AC_CHECK_FINK], [
sim_ac_have_fink=false
AC_MSG_CHECKING([if fink is available])
if test -d /sw/include && test -d /sw/lib; then
  AC_MSG_RESULT([yes])
  sim_ac_have_fink=true
  sim_ac_fink_cppflags="-I/sw/include"
  sim_ac_fink_ldflags="-L/sw/lib"
  CPPFLAGS="$CPPFLAGS $sim_ac_fink_cppflags"
  LDFLAGS="$LDFLAGS $sim_ac_fink_ldflags"
else 
  AC_MSG_RESULT([no])
  sim_ac_fink_cppflags=
  sim_ac_fink_ldflags=
fi

if $sim_ac_have_fink; then
  ifelse([$1], , :, [$1])
else
  ifelse([$2], , :, [$2])
fi

]) # SIM_AC_CHECK_FINK

